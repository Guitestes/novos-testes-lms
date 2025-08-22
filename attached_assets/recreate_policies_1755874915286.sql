-- Script SQL para recriar políticas RLS
-- Gerado automaticamente a partir de politicas.json
-- Data: 2025-08-22T12:38:03.085Z

-- Nota: As políticas existentes serão substituídas automaticamente pelos comandos CREATE POLICY
-- PostgreSQL permite recriar políticas com o mesmo nome sem precisar removê-las primeiro


-- Habilitar RLS para todas as tabelas
ALTER TABLE "academic_works" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "administrative_requests" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "calendar_events" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "campaign_metrics" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "classes" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "contracts" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "courses" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "courses_taught" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "custom_forms" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "customer_segments" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "documents" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "email_campaigns" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "email_list_contacts" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "email_lists" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "email_metrics" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "email_settings" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "email_subscribers" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "email_templates" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "email_tracking" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "enrollments" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "financial_transactions" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "general_documents" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "lead_interactions" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "leads" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "lessons" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "marketing_campaigns" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "members" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "module_prerequisites" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "modules" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "newsletter_templates" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "notifications" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "price_tables" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "professor_details" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "professor_payments" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "profile_scholarships" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "profiles" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "quizzes" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "request_comments" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "retention_actions" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "rooms" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "scholarships" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "service_price_list" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "service_providers" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "submission_answers" ENABLE ROW LEVEL SECURITY;

-- Políticas para tabela: academic_works
CREATE POLICY "Alunos podem inserir seus próprios trabalhos" ON "academic_works" AS PERMISSIVE FOR INSERT TO public WITH CHECK ((auth.uid() = user_id));
CREATE POLICY "Alunos podem ver seus próprios trabalhos" ON "academic_works" AS PERMISSIVE FOR SELECT TO public USING ((auth.uid() = user_id));
CREATE POLICY "Instrutores podem ver trabalhos de suas turmas" ON "academic_works" AS PERMISSIVE FOR SELECT TO public USING ((EXISTS ( SELECT 1
   FROM classes c
  WHERE ((c.id = academic_works.class_id) AND (c.instructor_id = auth.uid())))));

-- Políticas para tabela: administrative_requests
CREATE POLICY "Admins can delete requests" ON "administrative_requests" AS PERMISSIVE FOR DELETE TO authenticated USING (is_admin());
CREATE POLICY "Admins can update requests" ON "administrative_requests" AS PERMISSIVE FOR UPDATE TO authenticated USING (is_admin()) WITH CHECK (is_admin());
CREATE POLICY "Authenticated users can create requests" ON "administrative_requests" AS PERMISSIVE FOR INSERT TO authenticated WITH CHECK (((auth.uid() IS NOT NULL) AND (auth.uid() = user_id)));
CREATE POLICY "Users can view own requests" ON "administrative_requests" AS PERMISSIVE FOR SELECT TO authenticated USING (((auth.uid() IS NOT NULL) AND ((auth.uid() = user_id) OR is_admin())));

-- Políticas para tabela: calendar_events
CREATE POLICY "Admins can manage all calendar events" ON "calendar_events" AS PERMISSIVE FOR ALL TO public USING ((EXISTS ( SELECT 1
   FROM profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));
CREATE POLICY "Anyone can view calendar events" ON "calendar_events" AS PERMISSIVE FOR SELECT TO public USING (true);
CREATE POLICY "Enable insert for authenticated users only" ON "calendar_events" AS PERMISSIVE FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Enable read access for all users" ON "calendar_events" AS PERMISSIVE FOR SELECT TO public USING (true);
CREATE POLICY "Policy with table joins" ON "calendar_events" AS PERMISSIVE FOR UPDATE TO public USING ((( SELECT auth.uid() AS uid) IN ( SELECT members.user_id
   FROM members
  WHERE (members.team_id = calendar_events.id))));
CREATE POLICY "Professors can manage class events" ON "calendar_events" AS PERMISSIVE FOR ALL TO public USING ((EXISTS ( SELECT 1
   FROM (classes c
     JOIN profiles p ON ((c.instructor_id = p.id)))
  WHERE ((c.id = calendar_events.class_id) AND (p.id = auth.uid()) AND (p.role = ANY (ARRAY['professor'::text, 'admin'::text]))))));
CREATE POLICY "Users can view events of enrolled classes" ON "calendar_events" AS PERMISSIVE FOR SELECT TO public USING ((EXISTS ( SELECT 1
   FROM enrollments e
  WHERE ((e.user_id = auth.uid()) AND (e.class_id = calendar_events.class_id)))));

-- Políticas para tabela: campaign_metrics
CREATE POLICY "Admin can manage campaign metrics" ON "campaign_metrics" AS PERMISSIVE FOR ALL TO public USING ((EXISTS ( SELECT 1
   FROM profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));

-- Políticas para tabela: classes
CREATE POLICY "Admins can view all classes" ON "classes" AS PERMISSIVE FOR SELECT TO public USING ((EXISTS ( SELECT 1
   FROM profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));
CREATE POLICY "Enable insert for authenticated users only" ON "classes" AS PERMISSIVE FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Professors can create classes for their courses" ON "classes" AS PERMISSIVE FOR INSERT TO public WITH CHECK ((EXISTS ( SELECT 1
   FROM courses
  WHERE ((courses.id = classes.course_id) AND (courses.professor_id = auth.uid())))));
CREATE POLICY "Professors can view their course classes" ON "classes" AS PERMISSIVE FOR SELECT TO public USING ((EXISTS ( SELECT 1
   FROM courses
  WHERE ((courses.id = classes.course_id) AND (courses.professor_id = auth.uid())))));
CREATE POLICY "Students can view enrolled classes" ON "classes" AS PERMISSIVE FOR SELECT TO public USING ((EXISTS ( SELECT 1
   FROM enrollments
  WHERE ((enrollments.class_id = classes.id) AND (enrollments.user_id = auth.uid())))));
CREATE POLICY "allow_authenticated_users_view_classes" ON "classes" AS PERMISSIVE FOR SELECT TO authenticated USING (true);
CREATE POLICY "allow_public_view_classes" ON "classes" AS PERMISSIVE FOR SELECT TO anon USING (true);

-- Políticas para tabela: contracts
CREATE POLICY "Admins can manage all contracts" ON "contracts" AS PERMISSIVE FOR ALL TO public USING ((EXISTS ( SELECT 1
   FROM profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));

-- Políticas para tabela: courses
CREATE POLICY "Admins can manage all courses" ON "courses" AS PERMISSIVE FOR ALL TO public USING ((EXISTS ( SELECT 1
   FROM profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));
CREATE POLICY "Enable insert for authenticated users only" ON "courses" AS PERMISSIVE FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Enable read access for all users" ON "courses" AS PERMISSIVE FOR SELECT TO public USING (true);
CREATE POLICY "Policy with table joins" ON "courses" AS PERMISSIVE FOR UPDATE TO public USING ((( SELECT auth.uid() AS uid) IN ( SELECT members.user_id
   FROM members
  WHERE (members.team_id = courses.id))));
CREATE POLICY "Professors can create courses" ON "courses" AS PERMISSIVE FOR INSERT TO public WITH CHECK (((auth.uid() = professor_id) AND (EXISTS ( SELECT 1
   FROM profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = ANY (ARRAY['admin'::text, 'professor'::text])))))));
CREATE POLICY "Professors can update their own courses" ON "courses" AS PERMISSIVE FOR UPDATE TO public USING ((auth.uid() = professor_id)) WITH CHECK ((auth.uid() = professor_id));
CREATE POLICY "allow_public_view_courses" ON "courses" AS PERMISSIVE FOR SELECT TO public USING (true);

-- Políticas para tabela: courses_taught
CREATE POLICY "Admins can manage all taught courses" ON "courses_taught" AS PERMISSIVE FOR ALL TO public USING ((EXISTS ( SELECT 1
   FROM profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));
CREATE POLICY "Professors can view their own taught courses" ON "courses_taught" AS PERMISSIVE FOR SELECT TO public USING ((auth.uid() = professor_id));

-- Políticas para tabela: custom_forms
CREATE POLICY "Admins can manage custom forms" ON "custom_forms" AS PERMISSIVE FOR ALL TO public USING ((EXISTS ( SELECT 1
   FROM profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));
CREATE POLICY "Professors can create custom forms" ON "custom_forms" AS PERMISSIVE FOR INSERT TO public WITH CHECK ((EXISTS ( SELECT 1
   FROM profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = ANY (ARRAY['admin'::text, 'professor'::text]))))));
CREATE POLICY "Public can view custom forms" ON "custom_forms" AS PERMISSIVE FOR SELECT TO public USING (true);
CREATE POLICY "allow_form_read" ON "custom_forms" AS PERMISSIVE FOR SELECT TO authenticated USING (true);

-- Políticas para tabela: customer_segments
CREATE POLICY "Admins can manage customer segments" ON "customer_segments" AS PERMISSIVE FOR ALL TO public USING (is_admin(auth.uid()));

-- Políticas para tabela: documents
CREATE POLICY "Admins can manage all documents" ON "documents" AS PERMISSIVE FOR ALL TO public USING (is_admin()) WITH CHECK (is_admin());
CREATE POLICY "Users can create their own documents" ON "documents" AS PERMISSIVE FOR INSERT TO public WITH CHECK ((auth.uid() = user_id));
CREATE POLICY "Users can view their own documents" ON "documents" AS PERMISSIVE FOR SELECT TO public USING ((auth.uid() = user_id));

-- Políticas para tabela: email_campaigns
CREATE POLICY "Admins can manage email campaigns" ON "email_campaigns" AS PERMISSIVE FOR ALL TO public USING (is_admin(auth.uid()));

-- Políticas para tabela: email_list_contacts
CREATE POLICY "Admins can manage email list contacts" ON "email_list_contacts" AS PERMISSIVE FOR ALL TO public USING (is_admin(auth.uid()));

-- Políticas para tabela: email_lists
CREATE POLICY "Admin can manage email lists" ON "email_lists" AS PERMISSIVE FOR ALL TO public USING ((EXISTS ( SELECT 1
   FROM profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));

-- Políticas para tabela: email_metrics
CREATE POLICY "Admin can view email metrics" ON "email_metrics" AS PERMISSIVE FOR ALL TO public USING ((EXISTS ( SELECT 1
   FROM profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));

-- Políticas para tabela: email_settings
CREATE POLICY "Admins can manage email settings" ON "email_settings" AS PERMISSIVE FOR ALL TO authenticated USING (is_admin());

-- Políticas para tabela: email_subscribers
CREATE POLICY "Admins can manage email subscribers" ON "email_subscribers" AS PERMISSIVE FOR ALL TO authenticated USING (is_admin());

-- Políticas para tabela: email_templates
CREATE POLICY "Admin can manage email templates" ON "email_templates" AS PERMISSIVE FOR ALL TO public USING ((EXISTS ( SELECT 1
   FROM profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));

-- Políticas para tabela: email_tracking
CREATE POLICY "Admins can manage email tracking" ON "email_tracking" AS PERMISSIVE FOR ALL TO public USING (is_admin(auth.uid()));

-- Políticas para tabela: enrollments
CREATE POLICY "Admins can manage all enrollments" ON "enrollments" AS PERMISSIVE FOR ALL TO public USING (is_admin());
CREATE POLICY "Admins can view all enrollments" ON "enrollments" AS PERMISSIVE FOR SELECT TO public USING (is_admin());
CREATE POLICY "Users can create their own enrollments" ON "enrollments" AS PERMISSIVE FOR INSERT TO public WITH CHECK ((auth.uid() = user_id));
CREATE POLICY "Users can view their own enrollments" ON "enrollments" AS PERMISSIVE FOR SELECT TO public USING ((auth.uid() = user_id));

-- Políticas para tabela: financial_transactions
CREATE POLICY "Admins can manage all financial transactions" ON "financial_transactions" AS PERMISSIVE FOR ALL TO public USING ((EXISTS ( SELECT 1
   FROM profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));
CREATE POLICY "Users can view their own financial transactions" ON "financial_transactions" AS PERMISSIVE FOR SELECT TO public USING ((profile_id = auth.uid()));

-- Políticas para tabela: general_documents
CREATE POLICY "Admins podem gerenciar documentos gerais" ON "general_documents" AS PERMISSIVE FOR ALL TO public USING (((auth.jwt() ->> 'user_role'::text) = 'admin'::text)) WITH CHECK (((auth.jwt() ->> 'user_role'::text) = 'admin'::text));
CREATE POLICY "allow_authenticated_users_view_general_documents" ON "general_documents" AS PERMISSIVE FOR SELECT TO authenticated USING (true);

-- Políticas para tabela: lead_interactions
CREATE POLICY "Admin can manage lead interactions" ON "lead_interactions" AS PERMISSIVE FOR ALL TO public USING ((EXISTS ( SELECT 1
   FROM profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));

-- Políticas para tabela: leads
CREATE POLICY "Admin can manage leads" ON "leads" AS PERMISSIVE FOR ALL TO public USING ((EXISTS ( SELECT 1
   FROM profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));

-- Políticas para tabela: lessons
CREATE POLICY "Admins can manage all lessons" ON "lessons" AS PERMISSIVE FOR ALL TO public USING ((EXISTS ( SELECT 1
   FROM profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));
CREATE POLICY "Professors can manage lessons in their modules" ON "lessons" AS PERMISSIVE FOR ALL TO public USING ((EXISTS ( SELECT 1
   FROM (modules m
     JOIN courses c ON ((c.id = m.course_id)))
  WHERE ((m.id = lessons.module_id) AND (c.professor_id = auth.uid())))));
CREATE POLICY "allow_public_view_lessons" ON "lessons" AS PERMISSIVE FOR SELECT TO public USING (true);

-- Políticas para tabela: marketing_campaigns
CREATE POLICY "Admin can manage marketing campaigns" ON "marketing_campaigns" AS PERMISSIVE FOR ALL TO public USING ((EXISTS ( SELECT 1
   FROM profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));

-- Políticas para tabela: members
CREATE POLICY "Enable delete for users based on user_id" ON "members" AS PERMISSIVE FOR DELETE TO public USING ((( SELECT auth.uid() AS uid) = user_id));
CREATE POLICY "Enable insert for authenticated users only" ON "members" AS PERMISSIVE FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Enable read access for all users" ON "members" AS PERMISSIVE FOR SELECT TO public USING (true);

-- Políticas para tabela: module_prerequisites
CREATE POLICY "Enable insert for authenticated users only" ON "module_prerequisites" AS PERMISSIVE FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Enable read access for all users" ON "module_prerequisites" AS PERMISSIVE FOR SELECT TO public USING (true);

-- Políticas para tabela: modules
CREATE POLICY "Admins can manage all modules" ON "modules" AS PERMISSIVE FOR ALL TO public USING ((EXISTS ( SELECT 1
   FROM profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));
CREATE POLICY "Enable insert for authenticated users only" ON "modules" AS PERMISSIVE FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Enable read access for all users" ON "modules" AS PERMISSIVE FOR SELECT TO public USING (true);
CREATE POLICY "Policy with table joins" ON "modules" AS PERMISSIVE FOR UPDATE TO public USING ((( SELECT auth.uid() AS uid) IN ( SELECT members.user_id
   FROM members
  WHERE (members.team_id = modules.id))));
CREATE POLICY "Professors can manage their course modules" ON "modules" AS PERMISSIVE FOR ALL TO public USING ((EXISTS ( SELECT 1
   FROM courses
  WHERE ((courses.id = modules.course_id) AND (courses.professor_id = auth.uid())))));
CREATE POLICY "allow_public_view_modules" ON "modules" AS PERMISSIVE FOR SELECT TO public USING (true);

-- Políticas para tabela: newsletter_templates
CREATE POLICY "Admins can manage newsletter templates" ON "newsletter_templates" AS PERMISSIVE FOR ALL TO authenticated USING (is_admin());

-- Políticas para tabela: notifications
CREATE POLICY "Admins can see all notifications" ON "notifications" AS PERMISSIVE FOR SELECT TO public USING ((EXISTS ( SELECT 1
   FROM profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));
CREATE POLICY "Users can manage their own notifications" ON "notifications" AS PERMISSIVE FOR ALL TO public USING ((auth.uid() = user_id));

-- Políticas para tabela: price_tables
CREATE POLICY "Admins can manage all price tables" ON "price_tables" AS PERMISSIVE FOR ALL TO public USING ((EXISTS ( SELECT 1
   FROM profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));
CREATE POLICY "Service providers can view their own price tables" ON "price_tables" AS PERMISSIVE FOR SELECT TO public USING ((EXISTS ( SELECT 1
   FROM service_providers
  WHERE ((service_providers.id = price_tables.provider_id) AND (service_providers.user_id = auth.uid())))));

-- Políticas para tabela: professor_details
CREATE POLICY "Admins can manage all professor details" ON "professor_details" AS PERMISSIVE FOR ALL TO public USING ((EXISTS ( SELECT 1
   FROM profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));
CREATE POLICY "Professors can update their own details" ON "professor_details" AS PERMISSIVE FOR UPDATE TO public USING ((auth.uid() = user_id));
CREATE POLICY "Professors can view their own details" ON "professor_details" AS PERMISSIVE FOR SELECT TO public USING ((auth.uid() = user_id));

-- Políticas para tabela: professor_payments
CREATE POLICY "Admins can manage all professor payments" ON "professor_payments" AS PERMISSIVE FOR ALL TO public USING ((EXISTS ( SELECT 1
   FROM profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));
CREATE POLICY "Professors can view their own payments" ON "professor_payments" AS PERMISSIVE FOR SELECT TO public USING ((auth.uid() = professor_id));

-- Políticas para tabela: profile_scholarships
CREATE POLICY "Admins can manage all profile scholarships" ON "profile_scholarships" AS PERMISSIVE FOR ALL TO public USING ((EXISTS ( SELECT 1
   FROM profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));

-- Políticas para tabela: profiles
CREATE POLICY "Admins can manage all profiles" ON "profiles" AS PERMISSIVE FOR ALL TO public USING (is_admin()) WITH CHECK (is_admin());
CREATE POLICY "Admins can update all profiles" ON "profiles" AS PERMISSIVE FOR UPDATE TO public USING ((( SELECT (users.raw_user_meta_data ->> 'role'::text)
   FROM auth.users
  WHERE (users.id = auth.uid())) = 'admin'::text));
CREATE POLICY "Admins can view all profiles" ON "profiles" AS PERMISSIVE FOR SELECT TO public USING (is_admin());
CREATE POLICY "Authenticated users can view their own profiles" ON "profiles" AS PERMISSIVE FOR SELECT TO public USING ((auth.uid() = id));
CREATE POLICY "Users can update their own profiles" ON "profiles" AS PERMISSIVE FOR UPDATE TO public USING ((auth.uid() = id)) WITH CHECK ((auth.uid() = id));
CREATE POLICY "Users can view their own profiles" ON "profiles" AS PERMISSIVE FOR SELECT TO public USING ((auth.uid() = id));
CREATE POLICY "admin_can_delete_profiles" ON "profiles" AS PERMISSIVE FOR DELETE TO public USING (is_admin());
CREATE POLICY "admin_can_insert_profiles" ON "profiles" AS PERMISSIVE FOR INSERT TO public WITH CHECK ((is_admin() OR (auth.uid() = id)));
CREATE POLICY "admin_can_update_profiles" ON "profiles" AS PERMISSIVE FOR UPDATE TO public USING ((is_admin() OR (auth.uid() = id))) WITH CHECK ((is_admin() OR (auth.uid() = id)));
CREATE POLICY "admin_can_view_all_profiles" ON "profiles" AS PERMISSIVE FOR SELECT TO public USING ((is_admin() OR (auth.uid() = id)));
CREATE POLICY "basic_profile_access" ON "profiles" AS PERMISSIVE FOR ALL TO public USING ((auth.uid() = id)) WITH CHECK ((auth.uid() = id));

-- Políticas para tabela: quizzes
CREATE POLICY "Admins can manage all quizzes" ON "quizzes" AS PERMISSIVE FOR ALL TO public USING ((EXISTS ( SELECT 1
   FROM profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));
CREATE POLICY "Enable read access for all users" ON "quizzes" AS PERMISSIVE FOR SELECT TO public USING (true);
CREATE POLICY "Professors can manage quizzes in their courses" ON "quizzes" AS PERMISSIVE FOR ALL TO public USING ((EXISTS ( SELECT 1
   FROM courses c
  WHERE ((c.id = quizzes.course_id) AND (c.professor_id = auth.uid())))));

-- Políticas para tabela: request_comments
CREATE POLICY "Admins can manage all comments" ON "request_comments" AS PERMISSIVE FOR ALL TO public USING (is_admin(auth.uid())) WITH CHECK (is_admin(auth.uid()));
CREATE POLICY "Users can create comments on their accessible requests" ON "request_comments" AS PERMISSIVE FOR INSERT TO public WITH CHECK (( SELECT true
   FROM administrative_requests
  WHERE (administrative_requests.id = request_comments.request_id)));
CREATE POLICY "Users can view comments on their accessible requests" ON "request_comments" AS PERMISSIVE FOR SELECT TO public USING (( SELECT true
   FROM administrative_requests
  WHERE (administrative_requests.id = request_comments.request_id)));

-- Políticas para tabela: retention_actions
CREATE POLICY "Admins can manage retention actions" ON "retention_actions" AS PERMISSIVE FOR ALL TO public USING (is_admin(auth.uid())) WITH CHECK (is_admin(auth.uid()));

-- Políticas para tabela: rooms
CREATE POLICY "Admins can manage all rooms" ON "rooms" AS PERMISSIVE FOR ALL TO public USING ((EXISTS ( SELECT 1
   FROM profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));
CREATE POLICY "Anyone can view rooms" ON "rooms" AS PERMISSIVE FOR SELECT TO public USING (true);
CREATE POLICY "Enable insert for authenticated users only" ON "rooms" AS PERMISSIVE FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Enable read access for all users" ON "rooms" AS PERMISSIVE FOR SELECT TO public USING (true);
CREATE POLICY "Policy with table joins" ON "rooms" AS PERMISSIVE FOR UPDATE TO public USING ((( SELECT auth.uid() AS uid) IN ( SELECT members.user_id
   FROM members
  WHERE (members.team_id = rooms.id))));
CREATE POLICY "Professors can manage rooms" ON "rooms" AS PERMISSIVE FOR ALL TO public USING ((EXISTS ( SELECT 1
   FROM profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = ANY (ARRAY['professor'::text, 'admin'::text]))))));

-- Políticas para tabela: scholarships
CREATE POLICY "Admins can manage all scholarships" ON "scholarships" AS PERMISSIVE FOR ALL TO public USING ((EXISTS ( SELECT 1
   FROM profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));

-- Políticas para tabela: service_price_list
CREATE POLICY "Admins can manage price lists" ON "service_price_list" AS PERMISSIVE FOR ALL TO public USING (is_admin(auth.uid())) WITH CHECK (is_admin(auth.uid()));

-- Políticas para tabela: service_providers
CREATE POLICY "Admins can manage all service providers" ON "service_providers" AS PERMISSIVE FOR ALL TO public USING ((EXISTS ( SELECT 1
   FROM profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));

-- Políticas para tabela: submission_answers
CREATE POLICY "Enable insert for authenticated users only" ON "submission_answers" AS PERMISSIVE FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Enable read access for all users" ON "submission_answers" AS PERMISSIVE FOR SELECT TO public USING (true);
CREATE POLICY "Policy with table joins" ON "submission_answers" AS PERMISSIVE FOR UPDATE TO public USING ((( SELECT auth.uid() AS uid) IN ( SELECT members.user_id
   FROM members
  WHERE (members.team_id = submission_answers.id))));

