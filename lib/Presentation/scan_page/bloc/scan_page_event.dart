part of 'scan_page_bloc.dart';

sealed class ScanPageEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class InitScanPage extends ScanPageEvent {
  final File image;

  InitScanPage({required this.image});
}

class EditScanPage extends ScanPageEvent {}

class EditScanPageDispose extends ScanPageEvent {}
