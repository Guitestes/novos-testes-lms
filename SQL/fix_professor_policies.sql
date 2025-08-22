
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
