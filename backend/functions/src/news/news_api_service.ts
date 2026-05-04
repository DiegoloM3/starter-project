export interface NewsApiArticle {
  source: string;
  author: string;
  title: string;
  description: string;
  url: string;
  urlToImage: string;
  publishedAt: string;
  content: string;
}

export interface NewsApiService {
  fetchEverything(params: {
    query: string;
    pageSize: number;
    apiKey: string;
  }): Promise<NewsApiArticle[]>;
}

export class NewsApiServiceImpl implements NewsApiService {
  async fetchEverything({
    query,
    pageSize,
    apiKey,
  }: {
    query: string;
    pageSize: number;
    apiKey: string;
  }): Promise<NewsApiArticle[]> {
    const url = new URL('https://newsapi.org/v2/everything');
    url.searchParams.set('q', query);
    url.searchParams.set('language', 'en');
    url.searchParams.set('sortBy', 'publishedAt');
    url.searchParams.set('pageSize', String(pageSize));
    url.searchParams.set('apiKey', apiKey);

    const res = await fetch(url.toString());
    if (!res.ok) {
      throw new Error(`NewsAPI returned ${res.status}: ${res.statusText}`);
    }
    const body = (await res.json()) as {
      status: string;
      articles?: Array<{
        source?: { name?: string };
        author?: string;
        title?: string;
        description?: string;
        url?: string;
        urlToImage?: string;
        publishedAt?: string;
        content?: string;
      }>;
    };
    if (body.status !== 'ok') {
      throw new Error(`NewsAPI status=${body.status}`);
    }
    return (body.articles ?? []).map((a) => ({
      source: a.source?.name ?? '',
      author: a.author ?? '',
      title: a.title ?? '',
      description: a.description ?? '',
      url: a.url ?? '',
      urlToImage: a.urlToImage ?? '',
      publishedAt: a.publishedAt ?? '',
      content: a.content ?? '',
    }));
  }
}
