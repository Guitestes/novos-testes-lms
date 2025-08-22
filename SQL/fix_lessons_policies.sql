
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
