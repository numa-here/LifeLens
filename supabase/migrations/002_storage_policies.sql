create policy "Users upload documents to their own folder"
on storage.objects
for insert to authenticated
with check (
  bucket_id = 'documents'
  and (storage.foldername(name))[1] = (select auth.uid()::text)
);

create policy "Users read their own documents"
on storage.objects
for select to authenticated
using (
  bucket_id = 'documents'
  and (storage.foldername(name))[1] = (select auth.uid()::text)
);

create policy "Users delete their own documents"
on storage.objects
for delete to authenticated
using (
  bucket_id = 'documents'
  and (storage.foldername(name))[1] = (select auth.uid()::text)
);
