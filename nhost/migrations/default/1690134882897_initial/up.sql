SET check_function_bodies = false;
CREATE FUNCTION public.set_current_timestamp_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  _new record;
BEGIN
  _new := NEW;
  _new."updated_at" = NOW();
  RETURN _new;
END;
$$;
CREATE TABLE public.comments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    post_id uuid NOT NULL,
    profile_id uuid NOT NULL,
    comment text NOT NULL
);
COMMENT ON TABLE public.comments IS 'Post comments';
CREATE TABLE public.following (
    follower_profile_id uuid NOT NULL,
    following_profile_id uuid NOT NULL,
    is_accepted boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
COMMENT ON TABLE public.following IS 'User following/followers';
CREATE TABLE public.likes (
    post_id uuid NOT NULL,
    profile_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);
COMMENT ON TABLE public.likes IS 'Post likes';
CREATE TABLE public.posts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    profile_id uuid NOT NULL,
    media_id uuid NOT NULL,
    caption text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now()
);
COMMENT ON TABLE public.posts IS 'Posts';
CREATE TABLE public.profiles (
    id uuid NOT NULL,
    username text NOT NULL,
    description text NOT NULL,
    is_private boolean NOT NULL,
    admin_approved boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);
COMMENT ON TABLE public.profiles IS 'Profiles';
ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.following
    ADD CONSTRAINT following_pkey PRIMARY KEY (follower_profile_id, following_profile_id);
ALTER TABLE ONLY public.likes
    ADD CONSTRAINT likes_pkey PRIMARY KEY (post_id, profile_id);
ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_username_key UNIQUE (username);
CREATE TRIGGER set_public_following_updated_at BEFORE UPDATE ON public.following FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_following_updated_at ON public.following IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_posts_updated_at BEFORE UPDATE ON public.posts FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_posts_updated_at ON public.posts IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_profiles_updated_at ON public.profiles IS 'trigger to set value of column "updated_at" to current timestamp on row update';
ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public.following
    ADD CONSTRAINT following_following_profile_id_fkey FOREIGN KEY (following_profile_id) REFERENCES public.profiles(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public.following
    ADD CONSTRAINT following_profile_id_fkey FOREIGN KEY (follower_profile_id) REFERENCES public.profiles(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public.likes
    ADD CONSTRAINT likes_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public.likes
    ADD CONSTRAINT likes_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_media_id_fkey FOREIGN KEY (media_id) REFERENCES storage.files(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_user_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE CASCADE;
