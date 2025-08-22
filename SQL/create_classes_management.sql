
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
