-- ==============================================================================
-- SCRIPT DE POLÍTICAS DE STORAGE Y RLS PARA AERONPULSE / VIKUS
-- Verificado contra la estructura real de Supabase (tablas: businesses y business_photos)
-- ==============================================================================

-- 1. CONFIGURACIÓN DEL BUCKET 'business-photos'
-- Asegura que el bucket exista y sea público para visualización sin borrar archivos existentes
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'business-photos',
  'business-photos',
  true,
  10485760, -- Límite de 10MB por imagen
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif']
)
ON CONFLICT (id) DO UPDATE SET
  public = true,
  file_size_limit = 10485760,
  allowed_mime_types = ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif'];


-- 2. POLÍTICAS DE SEGURIDAD EN STORAGE (storage.objects)
-- Se eliminan solo las políticas con el mismo nombre si existieran para evitar duplicados
DROP POLICY IF EXISTS "Public Read Business Photos" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Users Can Upload Business Photos" ON storage.objects;
DROP POLICY IF EXISTS "Owners Can Update Business Photos" ON storage.objects;
DROP POLICY IF EXISTS "Owners Can Delete Business Photos" ON storage.objects;

-- Permiso para que cualquier persona pueda VER / DESCARGAR las fotos (Público)
CREATE POLICY "Public Read Business Photos"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'business-photos');

-- Permiso para que usuarios autenticados puedan SUBIR fotos
CREATE POLICY "Authenticated Users Can Upload Business Photos"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'business-photos');

-- Permiso para que el propietario pueda ACTUALIZAR sus fotos
CREATE POLICY "Owners Can Update Business Photos"
ON storage.objects
FOR UPDATE
TO authenticated
USING (
  bucket_id = 'business-photos' AND (
    auth.uid() = owner OR
    EXISTS (
      SELECT 1 FROM public.businesses b
      WHERE b.id::text = split_part(name, '/', 1)
        AND b.owner_id = auth.uid()
    )
  )
)
WITH CHECK (
  bucket_id = 'business-photos'
);

-- Permiso para que el propietario pueda ELIMINAR sus fotos (Seguridad Multi-inquilino)
CREATE POLICY "Owners Can Delete Business Photos"
ON storage.objects
FOR DELETE
TO authenticated
USING (
  bucket_id = 'business-photos' AND (
    auth.uid() = owner OR
    EXISTS (
      SELECT 1 FROM public.businesses b
      WHERE b.id::text = split_part(name, '/', 1)
        AND b.owner_id = auth.uid()
    )
  )
);


-- 3. POLÍTICAS RLS EN LA TABLA 'public.business_photos'
ALTER TABLE public.business_photos ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public View Business Photos" ON public.business_photos;
DROP POLICY IF EXISTS "Owners Can Insert Business Photos" ON public.business_photos;
DROP POLICY IF EXISTS "Owners Can Update Business Photos" ON public.business_photos;
DROP POLICY IF EXISTS "Owners Can Delete Business Photos" ON public.business_photos;

-- Ver fotos públicamente
CREATE POLICY "Public View Business Photos"
ON public.business_photos
FOR SELECT
TO public
USING (true);

-- Insertar fotos asociadas a negocios propios (businesses.owner_id = auth.uid())
CREATE POLICY "Owners Can Insert Business Photos"
ON public.business_photos
FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.businesses b
    WHERE b.id = business_photos.business_id
      AND b.owner_id = auth.uid()
  )
);

-- Actualizar fotos asociadas a negocios propios
CREATE POLICY "Owners Can Update Business Photos"
ON public.business_photos
FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.businesses b
    WHERE b.id = business_photos.business_id
      AND b.owner_id = auth.uid()
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.businesses b
    WHERE b.id = business_photos.business_id
      AND b.owner_id = auth.uid()
  )
);

-- Eliminar fotos asociadas a negocios propios
CREATE POLICY "Owners Can Delete Business Photos"
ON public.business_photos
FOR DELETE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.businesses b
    WHERE b.id = business_photos.business_id
      AND b.owner_id = auth.uid()
  )
);
