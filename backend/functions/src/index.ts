import { initializeApp, getApps } from 'firebase-admin/app';

if (getApps().length === 0) {
  initializeApp();
}

export { embedArticleOnWrite } from './article/embed_on_write';
export { searchArticles } from './article/search_articles';
export { backfillEmbeddings } from './article/backfill_embeddings';
export { recommendForUser } from './recommendation/recommend_for_user';
