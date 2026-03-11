DROP TRIGGER IF EXISTS trg_provider_accounts_set_updated_at ON ops.provider_accounts;

CREATE TRIGGER trg_provider_accounts_set_updated_at
BEFORE UPDATE ON ops.provider_accounts
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();