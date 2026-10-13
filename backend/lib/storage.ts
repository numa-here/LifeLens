import { del, list } from '@vercel/blob';

export async function deleteUserFiles(userId: string) {
  try {
    const { blobs } = await list({ prefix: userId });

    if (blobs && blobs.length > 0) {
      const urls = blobs.map((blob) => blob.url);
      await del(urls);
    }

    return { success: true, deletedCount: blobs?.length || 0 };
  } catch (error) {
    console.error('Delete user files error:', error);
    return { success: false, error: 'Failed to delete files' };
  }
}

export async function getUserFiles(userId: string) {
  try {
    const { blobs } = await list({ prefix: userId });
    return { success: true, files: blobs || [] };
  } catch (error) {
    console.error('Get user files error:', error);
    return { success: false, error: 'Failed to list files' };
  }
}
