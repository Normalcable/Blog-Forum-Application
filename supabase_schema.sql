-- ========================================================
-- DISCOURSE BLOG FORUM - SUPABASE DATABASE SCHEMA & RLS
-- Copy and paste this script into your Supabase SQL Editor.
-- ========================================================

-- 1. Create PROFILES Table
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  display_name TEXT NOT NULL,
  username TEXT UNIQUE NOT NULL,
  bio TEXT DEFAULT '',
  avatar_url TEXT DEFAULT '',
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. Create POSTS Table
CREATE TABLE IF NOT EXISTS public.posts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  author_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  community TEXT DEFAULT 'general' NOT NULL,
  tags TEXT[] DEFAULT '{}'::TEXT[],
  image_urls TEXT[] DEFAULT '{}'::TEXT[],
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. Create COMMENTS Table
CREATE TABLE IF NOT EXISTS public.comments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  post_id UUID REFERENCES public.posts(id) ON DELETE CASCADE NOT NULL,
  author_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  content TEXT NOT NULL,
  image_urls TEXT[] DEFAULT '{}'::TEXT[],
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 4. Create POST LIKES Table
CREATE TABLE IF NOT EXISTS public.post_likes (
  post_id UUID REFERENCES public.posts(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  PRIMARY KEY (post_id, user_id)
);

-- ========================================================
-- STORAGE BUCKETS FOR MEDIA UPLOADS
-- ========================================================
INSERT INTO storage.buckets (id, name, public)
VALUES ('posts', 'posts', true), ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

-- Storage Policies
CREATE POLICY "Public Read Access for Posts Bucket" ON storage.objects
  FOR SELECT USING (bucket_id = 'posts');

CREATE POLICY "Authenticated Upload for Posts Bucket" ON storage.objects
  FOR INSERT WITH CHECK (bucket_id = 'posts' AND auth.role() = 'authenticated');

CREATE POLICY "Public Read Access for Avatars Bucket" ON storage.objects
  FOR SELECT USING (bucket_id = 'avatars');

CREATE POLICY "Authenticated Upload for Avatars Bucket" ON storage.objects
  FOR INSERT WITH CHECK (bucket_id = 'avatars' AND auth.role() = 'authenticated');

-- ========================================================
-- TRIGGER FOR AUTOMATIC PROFILE CREATION ON USER SIGNUP
-- ========================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, display_name, username, bio, avatar_url)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name', 'Discourse User'),
    COALESCE(NEW.raw_user_meta_data->>'username', CONCAT('user_', SUBSTRING(NEW.id::text, 1, 8))),
    'Member of the Discourse community.',
    ''
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ========================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ========================================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.post_likes ENABLE ROW LEVEL SECURITY;

-- PROFILES Policies
CREATE POLICY "Public profiles are viewable by everyone." ON public.profiles
  FOR SELECT USING (true);

CREATE POLICY "Users can insert their own profile." ON public.profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update their own profile." ON public.profiles
  FOR UPDATE USING (auth.uid() = id);

-- POSTS Policies
CREATE POLICY "Posts are viewable by everyone." ON public.posts
  FOR SELECT USING (true);

CREATE POLICY "Authenticated users can create posts." ON public.posts
  FOR INSERT WITH CHECK (auth.role() = 'authenticated' AND auth.uid() = author_id);

CREATE POLICY "Authors can update their own posts." ON public.posts
  FOR UPDATE USING (auth.uid() = author_id);

CREATE POLICY "Authors can delete their own posts." ON public.posts
  FOR DELETE USING (auth.uid() = author_id);

-- COMMENTS Policies
CREATE POLICY "Comments are viewable by everyone." ON public.comments
  FOR SELECT USING (true);

CREATE POLICY "Authenticated users can create comments." ON public.comments
  FOR INSERT WITH CHECK (auth.role() = 'authenticated' AND auth.uid() = author_id);

CREATE POLICY "Authors can delete their own comments." ON public.comments
  FOR DELETE USING (auth.uid() = author_id);

-- POST LIKES Policies
CREATE POLICY "Likes are viewable by everyone." ON public.post_likes
  FOR SELECT USING (true);

CREATE POLICY "Authenticated users can toggle likes." ON public.post_likes
  FOR INSERT WITH CHECK (auth.role() = 'authenticated' AND auth.uid() = user_id);

CREATE POLICY "Users can remove their own likes." ON public.post_likes
  FOR DELETE USING (auth.uid() = user_id);
