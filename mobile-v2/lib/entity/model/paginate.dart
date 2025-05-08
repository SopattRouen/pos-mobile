class Paginate<T> {
  int? currentPage;
  int? lastPage;
  int? itemPerPage;
  List<T>? data;

  Paginate({
    this.currentPage = 1, 
    this.lastPage = 1, 
    this.itemPerPage,
    this.data,
  }); 
}