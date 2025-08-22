
-- Corrigir schema da tabela courses para coincidir com o código
ALTER TABLE public.courses 
ADD COLUMN IF NOT EXISTS level TEXT CHECK (level IN ('beginner', 'intermediate', 'advanced'));

ALTER TABLE public.courses 
ADD COLUMN IF NOT EXISTS duration_hours INTEGER DEFAULT 0;

ALTER TABLE public.courses 
ADD COLUMN IF NOT EXISTS price NUMERIC(10,2) DEFAULT 0;

-- Garantir que os campos essenciais existam
ALTER TABLE public.courses 
ALTER COLUMN status SET DEFAULT 'pending';

-- Atualizar campos existentes para usar nomes corretos
UPDATE public.courses SET status = 'pending' WHERE status IS NULL;

-- Adicionar constraints necessárias
ALTER TABLE public.courses 
ADD CONSTRAINT courses_status_check 
CHECK (status IN ('pending', 'approved', 'rejected', 'draft'));

ALTER TABLE public.courses 
ADD CONSTRAINT courses_level_check 
CHECK (level IN ('beginner', 'intermediate', 'advanced'));
