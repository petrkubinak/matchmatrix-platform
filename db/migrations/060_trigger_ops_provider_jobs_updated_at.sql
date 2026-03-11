DROP TRIGGER IF EXISTS trg_provider_jobs_set_updated_at ON ops.provider_jobs;

CREATE TRIGGER trg_provider_jobs_set_updated_at
BEFORE UPDATE ON ops.provider_jobs
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();