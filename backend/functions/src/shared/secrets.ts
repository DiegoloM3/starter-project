import { defineSecret } from 'firebase-functions/params';

export const GEMINI_API_KEY = defineSecret('GEMINI_API_KEY');
export const NEWS_API_KEY = defineSecret('NEWS_API_KEY');
