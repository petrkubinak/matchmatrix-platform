--Vyčistit dnešní queue a naplnit ji znovu

DELETE FROM ops.scheduler_queue
WHERE queue_day = CURRENT_DATE;