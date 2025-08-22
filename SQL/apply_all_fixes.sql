
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

-- Remover políticas conflitantes
DROP POLICY IF EXISTS "Professors can create courses" ON public.courses;
DROP POLICY IF EXISTS "Professors can update their own courses" ON public.courses;
DROP POLICY IF EXISTS "Professors can view their own courses" ON public.courses;

-- Política para professores criarem cursos
CREATE POLICY "Professors can create courses"
ON public.courses
FOR INSERT
TO authenticated
WITH CHECK (
  auth.uid() = professor_id AND
  EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE id = auth.uid() AND role = 'professor'
  )
);

-- Política para professores visualizarem seus próprios cursos
CREATE POLICY "Professors can view their own courses"
ON public.courses
FOR SELECT
TO authenticated
USING (
  auth.uid() = professor_id OR
  status = 'approved' OR
  EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE id = auth.uid() AND role = 'admin'
  )
);

-- Política para professores atualizarem seus próprios cursos (apenas se pendentes)
CREATE POLICY "Professors can update their own courses"
ON public.courses
FOR UPDATE
TO authenticated
USING (
  auth.uid() = professor_id AND 
  status IN ('pending', 'draft')
)
WITH CHECK (
  auth.uid() = professor_id AND 
  status IN ('pending', 'draft')
);

-- Política para admins gerenciarem todos os cursos
CREATE POLICY "Admins can manage all courses"
ON public.courses
FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE id = auth.uid() AND role = 'admin'
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE id = auth.uid() AND role = 'admin'
  )
);

-- Remover políticas conflitantes para módulos
DROP POLICY IF EXISTS "Professors can manage their course modules" ON public.modules;
DROP POLICY IF EXISTS "Professors can create modules for their courses" ON public.modules;

-- Política para professores criarem módulos nos seus cursos
CREATE POLICY "Professors can create modules for their courses"
ON public.modules
FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.courses 
    WHERE id = course_id AND professor_id = auth.uid()
  )
);

-- Política para professores visualizarem módulos dos seus cursos
CREATE POLICY "Professors can view their course modules"
ON public.modules
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.courses 
    WHERE id = course_id AND (professor_id = auth.uid() OR status = 'approved')
  ) OR
  EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE id = auth.uid() AND role = 'admin'
  )
);

-- Política para professores atualizarem módulos dos seus cursos
CREATE POLICY "Professors can update their course modules"
ON public.modules
FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.courses 
    WHERE id = course_id AND professor_id = auth.uid() AND status IN ('pending', 'draft')
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.courses 
    WHERE id = course_id AND professor_id = auth.uid() AND status IN ('pending', 'draft')
  )
);

-- Política para professores deletarem módulos dos seus cursos
CREATE POLICY "Professors can delete their course modules"
ON public.modules
FOR DELETE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.courses 
    WHERE id = course_id AND professor_id = auth.uid() AND status IN ('pending', 'draft')
  )
);

-- Remover políticas conflitantes para lições
DROP POLICY IF EXISTS "Professors can manage lessons in their modules" ON public.lessons;

-- Política para professores criarem lições nos seus módulos
CREATE POLICY "Professors can create lessons in their modules"
ON public.lessons
FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.modules m
    JOIN public.courses c ON c.id = m.course_id
    WHERE m.id = module_id AND c.professor_id = auth.uid()
  )
);

-- Política para professores visualizarem lições dos seus módulos
CREATE POLICY "Professors can view their module lessons"
ON public.lessons
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.modules m
    JOIN public.courses c ON c.id = m.course_id
    WHERE m.id = module_id AND (c.professor_id = auth.uid() OR c.status = 'approved')
  ) OR
  EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE id = auth.uid() AND role = 'admin'
  )
);

-- Política para professores atualizarem lições dos seus módulos
CREATE POLICY "Professors can update their module lessons"
ON public.lessons
FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.modules m
    JOIN public.courses c ON c.id = m.course_id
    WHERE m.id = module_id AND c.professor_id = auth.uid() AND c.status IN ('pending', 'draft')
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.modules m
    JOIN public.courses c ON c.id = m.course_id
    WHERE m.id = module_id AND c.professor_id = auth.uid() AND c.status IN ('pending', 'draft')
  )
);

-- Política para professores deletarem lições dos seus módulos
CREATE POLICY "Professors can delete their module lessons"
ON public.lessons
FOR DELETE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.modules m
    JOIN public.courses c ON c.id = m.course_id
    WHERE m.id = module_id AND c.professor_id = auth.uid() AND c.status IN ('pending', 'draft')
  )
);

-- Função para aprovar curso
CREATE OR REPLACE FUNCTION public.approve_course(p_course_id UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Verificar se o usuário é admin
    IF NOT public.is_admin() THEN
        RAISE EXCEPTION 'Apenas administradores podem aprovar cursos';
    END IF;
    
    -- Atualizar status do curso
    UPDATE public.courses 
    SET 
        status = 'approved',
        approved_by = auth.uid(),
        approved_at = NOW(),
        updated_at = NOW()
    WHERE id = p_course_id AND status = 'pending';
    
    -- Verificar se o curso foi encontrado e atualizado
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Curso não encontrado ou não está pendente';
    END IF;
    
    -- Criar notificação para o professor
    INSERT INTO public.notifications (user_id, message, type, link)
    SELECT 
        professor_id,
        'Seu curso "' || title || '" foi aprovado e está disponível para matrículas!',
        'course_approved',
        '/professor/courses/' || id
    FROM public.courses 
    WHERE id = p_course_id;
END;
$$;

-- Função para rejeitar curso
CREATE OR REPLACE FUNCTION public.reject_course(p_course_id UUID, p_rejection_reason TEXT)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Verificar se o usuário é admin
    IF NOT public.is_admin() THEN
        RAISE EXCEPTION 'Apenas administradores podem rejeitar cursos';
    END IF;
    
    -- Verificar se foi fornecido um motivo
    IF p_rejection_reason IS NULL OR trim(p_rejection_reason) = '' THEN
        RAISE EXCEPTION 'É obrigatório fornecer um motivo para rejeição';
    END IF;
    
    -- Atualizar status do curso
    UPDATE public.courses 
    SET 
        status = 'rejected',
        approved_by = auth.uid(),
        approved_at = NOW(),
        rejection_reason = p_rejection_reason,
        updated_at = NOW()
    WHERE id = p_course_id AND status = 'pending';
    
    -- Verificar se o curso foi encontrado e atualizado
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Curso não encontrado ou não está pendente';
    END IF;
    
    -- Criar notificação para o professor
    INSERT INTO public.notifications (user_id, message, type, link)
    SELECT 
        professor_id,
        'Seu curso "' || title || '" foi rejeitado. Motivo: ' || p_rejection_reason,
        'course_rejected',
        '/professor/courses/' || id
    FROM public.courses 
    WHERE id = p_course_id;
END;
$$;

-- Política para professores criarem turmas nos seus cursos
DROP POLICY IF EXISTS "Professors can create classes for their courses" ON public.classes;
CREATE POLICY "Professors can create classes for their courses"
ON public.classes
FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.courses 
    WHERE id = course_id AND professor_id = auth.uid()
  )
);

-- Política para professores visualizarem turmas dos seus cursos
DROP POLICY IF EXISTS "Professors can view their course classes" ON public.classes;
CREATE POLICY "Professors can view their course classes"
ON public.classes
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.courses 
    WHERE id = course_id AND (professor_id = auth.uid() OR status = 'approved')
  ) OR
  EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE id = auth.uid() AND role = 'admin'
  )
);

-- Política para professores atualizarem turmas dos seus cursos
DROP POLICY IF EXISTS "Professors can update their course classes" ON public.classes;
CREATE POLICY "Professors can update their course classes"
ON public.classes
FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.courses 
    WHERE id = course_id AND professor_id = auth.uid()
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.courses 
    WHERE id = course_id AND professor_id = auth.uid()
  )
);

-- Política para professores deletarem turmas dos seus cursos
DROP POLICY IF EXISTS "Professors can delete their course classes" ON public.classes;
CREATE POLICY "Professors can delete their course classes"
ON public.classes
FOR DELETE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.courses 
    WHERE id = course_id AND professor_id = auth.uid()
  )
);

-- Função para criar turma
CREATE OR REPLACE FUNCTION public.create_class(
  p_course_id UUID,
  p_class_name TEXT,
  p_schedule TEXT,
  p_room_id UUID DEFAULT NULL,
  p_max_students INTEGER DEFAULT 30,
  p_start_date DATE DEFAULT NULL,
  p_end_date DATE DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_class_id UUID;
  v_professor_id UUID;
BEGIN
  -- Verificar se o usuário é o professor do curso
  SELECT professor_id INTO v_professor_id
  FROM public.courses 
  WHERE id = p_course_id;
  
  IF v_professor_id != auth.uid() THEN
    RAISE EXCEPTION 'Apenas o professor do curso pode criar turmas';
  END IF;
  
  -- Criar a turma
  INSERT INTO public.classes (
    course_id,
    name,
    schedule,
    room_id,
    max_students,
    start_date,
    end_date,
    created_by,
    updated_at
  ) VALUES (
    p_course_id,
    p_class_name,
    p_schedule,
    p_room_id,
    p_max_students,
    p_start_date,
    p_end_date,
    auth.uid(),
    NOW()
  )
  RETURNING id INTO v_class_id;
  
  RETURN v_class_id;
END;
$$;

-- Função para obter turmas do professor
CREATE OR REPLACE FUNCTION public.get_professor_classes(p_professor_id UUID DEFAULT NULL)
RETURNS TABLE (
  class_id UUID,
  class_name TEXT,
  course_title TEXT,
  course_id UUID,
  schedule TEXT,
  max_students INTEGER,
  enrolled_count BIGINT,
  start_date DATE,
  end_date DATE,
  status TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_professor_id UUID;
BEGIN
  v_professor_id := COALESCE(p_professor_id, auth.uid());
  
  -- Verificar se o usuário pode acessar estes dados
  IF v_professor_id != auth.uid() AND NOT public.is_admin() THEN
    RAISE EXCEPTION 'Acesso negado';
  END IF;
  
  RETURN QUERY
  SELECT 
    cl.id as class_id,
    cl.name as class_name,
    c.title as course_title,
    c.id as course_id,
    cl.schedule,
    cl.max_students,
    COUNT(e.id) as enrolled_count,
    cl.start_date,
    cl.end_date,
    CASE 
      WHEN cl.end_date < CURRENT_DATE THEN 'finished'
      WHEN cl.start_date > CURRENT_DATE THEN 'upcoming'
      ELSE 'active'
    END as status
  FROM public.classes cl
  JOIN public.courses c ON c.id = cl.course_id
  LEFT JOIN public.enrollments e ON e.class_id = cl.id
  WHERE c.professor_id = v_professor_id
  GROUP BY cl.id, cl.name, c.title, c.id, cl.schedule, cl.max_students, cl.start_date, cl.end_date
  ORDER BY cl.created_at DESC;
END;
$$;
