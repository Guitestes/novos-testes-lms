
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
