class PaginationManager {
  int currentPage = 0;
  int totalPages = 1;
  bool isLoading = false;
  bool hasMore = true;
  final Set<int> loadedPages = {};

  bool canLoadMore() => hasMore && !isLoading;

  bool shouldFetchPage(int page) {
    return !loadedPages.contains(page) && !isLoading;
  }

  void onPageLoaded(int page, int total) {
    loadedPages.add(page);
    currentPage = page;
    totalPages = total;
    hasMore = page < totalPages;
    isLoading = false;
  }

  void startLoading() => isLoading = true;

  void stopLoading() => isLoading = false;

  int nextPage() => currentPage + 1;

  void reset() {
    currentPage = 0;
    totalPages = 1;
    isLoading = false;
    hasMore = true;
    loadedPages.clear();
  }
}
