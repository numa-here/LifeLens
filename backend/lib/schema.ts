import { pgTable, uuid, text, timestamp, date, index } from 'drizzle-orm/pg-core';

export const scanHistory = pgTable(
  'scan_history',
  {
    id: uuid('id').primaryKey().defaultRandom(),
    userId: uuid('user_id').notNull(),
    filePath: text('file_path'),
    originalText: text('original_text'),
    detectedLanguage: text('detected_language'),
    summary: text('summary'),
    createdAt: timestamp('created_at').notNull().defaultNow(),
  },
  (table) => ({
    userIdIdx: index('scans_user_created_idx').on(table.userId, table.createdAt),
  })
);

export const tasks = pgTable(
  'tasks',
  {
    id: uuid('id').primaryKey().defaultRandom(),
    userId: uuid('user_id').notNull(),
    scanId: uuid('scan_id').references(() => scanHistory.id, { onDelete: 'set null' }),
    title: text('title').notNull(),
    description: text('description'),
    dueDate: date('due_date'),
    priority: text('priority').notNull().default('medium'),
    sourceEvidence: text('source_evidence'),
    status: text('status').notNull().default('pending'),
    createdAt: timestamp('created_at').notNull().defaultNow(),
  },
  (table) => ({
    userDueDateIdx: index('tasks_user_due_date_idx').on(table.userId, table.dueDate),
  })
);

export type ScanHistory = typeof scanHistory.$inferSelect;
export type NewScanHistory = typeof scanHistory.$inferInsert;
export type Task = typeof tasks.$inferSelect;
export type NewTask = typeof tasks.$inferInsert;
