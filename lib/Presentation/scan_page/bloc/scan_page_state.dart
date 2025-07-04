part of 'scan_page_bloc.dart';

enum ScanPageStatus { initial, loading, failed, success, finish }

class ScanPageState extends Equatable {
  const ScanPageState({
    this.status = ScanPageStatus.initial,
    this.billItem,
    this.errorMessage,
    this.controllers = const [],
    this.isEdit = false,
    this.id = '',
  });

  final ScanPageStatus status;
  final BillItemModel? billItem;
  final bool isEdit;
  final List<TextEditingController> controllers;
  final String? errorMessage;
  final String id;

  ScanPageState copyWith({
    ScanPageStatus? status,
    BillItemModel? billItem,
    bool? isEdit,
    List<TextEditingController>? controllers,
    String? errorMessage,
    String? id,
  }) {
    return ScanPageState(
      status: status ?? this.status,
      billItem: billItem ?? this.billItem,
      isEdit: isEdit ?? this.isEdit,
      controllers: controllers ?? this.controllers,
      errorMessage: errorMessage ?? this.errorMessage,
      id: id ?? this.id,
    );
  }

  @override
  List<Object?> get props => [
    status,
    billItem,
    isEdit,
    controllers,
    errorMessage,
    id,
  ];
}
