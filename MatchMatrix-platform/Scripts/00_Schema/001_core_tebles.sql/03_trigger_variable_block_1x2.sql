-- db/migrations/20260219_03_trigger_variable_block_1x2.sql
-- Vynucení pravidel:
--  - template_blocks.block_type = 'VARIABLE' => template_block_matches.market_id musí být market code 'h2h' (1X2)
--  - 'VARIABLE' blok může mít 0..3 zápasy (tj. max 3 řádky v template_block_matches pro template_id+block_index)

BEGIN;

-- 1) Helper: id marketu pro 1X2 (v DB je to "h2h" dle ingest skriptů)
--    Pokud bys někde měl jiný kód, uprav 'h2h'.
CREATE OR REPLACE FUNCTION public.mm_market_h2h_id()
RETURNS bigint
LANGUAGE sql
STABLE
AS $$
  SELECT id
  FROM public.markets
  WHERE lower(code) = lower('h2h')
  LIMIT 1
$$;

-- 2) Trigger funkce pro kontrolu
CREATE OR REPLACE FUNCTION public.trg_template_block_matches_guard()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  v_block_type text;
  v_h2h_market_id bigint;
  v_cnt int;
BEGIN
  -- zjisti typ bloku
  SELECT tb.block_type
    INTO v_block_type
  FROM public.template_blocks tb
  WHERE tb.template_id = NEW.template_id
    AND tb.block_index = NEW.block_index;

  IF v_block_type IS NULL THEN
    RAISE EXCEPTION 'template_blocks missing for template_id=% block_index=%',
      NEW.template_id, NEW.block_index;
  END IF;

  -- pokud VARIABLE => market musí být h2h a max 3 zápasy
  IF v_block_type = 'VARIABLE' THEN
    v_h2h_market_id := public.mm_market_h2h_id();

    IF v_h2h_market_id IS NULL THEN
      RAISE EXCEPTION 'Market code=h2h not found in public.markets';
    END IF;

    IF NEW.market_id <> v_h2h_market_id THEN
      RAISE EXCEPTION 'VARIABLE block requires market_id=h2h (expected %, got %)',
        v_h2h_market_id, NEW.market_id;
    END IF;

    -- limit max 3 zápasy v bloku
    SELECT COUNT(*)
      INTO v_cnt
    FROM public.template_block_matches m
    WHERE m.template_id = NEW.template_id
      AND m.block_index = NEW.block_index;

    -- při INSERT ještě řádek neexistuje => >=3 znamená, že by to byl 4.
    IF TG_OP = 'INSERT' AND v_cnt >= 3 THEN
      RAISE EXCEPTION 'VARIABLE block limit exceeded: max 3 matches (template_id=%, block_index=%)',
        NEW.template_id, NEW.block_index;
    END IF;

    -- při UPDATE můžeš přesouvat mezi bloky: zkontroluj cílový blok (pokud se mění)
    IF TG_OP = 'UPDATE' AND (NEW.template_id <> OLD.template_id OR NEW.block_index <> OLD.block_index) THEN
      SELECT COUNT(*)
        INTO v_cnt
      FROM public.template_block_matches m
      WHERE m.template_id = NEW.template_id
        AND m.block_index = NEW.block_index;

      IF v_cnt >= 3 THEN
        RAISE EXCEPTION 'VARIABLE block limit exceeded on move: max 3 matches (template_id=%, block_index=%)',
          NEW.template_id, NEW.block_index;
      END IF;
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

-- 3) Trigger na tabulku template_block_matches
DROP TRIGGER IF EXISTS template_block_matches_guard ON public.template_block_matches;

CREATE TRIGGER template_block_matches_guard
BEFORE INSERT OR UPDATE ON public.template_block_matches
FOR EACH ROW
EXECUTE FUNCTION public.trg_template_block_matches_guard();

COMMIT;

