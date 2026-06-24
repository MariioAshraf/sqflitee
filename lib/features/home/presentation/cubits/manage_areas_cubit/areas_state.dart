import 'package:equatable/equatable.dart';
import '../../../data/models/area_with_streets_model.dart';

sealed class AreasState extends Equatable {
  const AreasState();
  @override
  List<Object?> get props => [];
}

final class AreasInitial extends AreasState {
  const AreasInitial();
}

final class AreasLoaded extends AreasState {
  final List<AreaWithStreets> areasWithStreets;
  final bool isSyncing;

  const AreasLoaded(this.areasWithStreets, {this.isSyncing = false});

  @override
  List<Object?> get props => [areasWithStreets, isSyncing];

  AreasLoaded copyWith({
    List<AreaWithStreets>? areasWithStreets,
    bool? isSyncing,
  }) => AreasLoaded(
    areasWithStreets ?? this.areasWithStreets,
    isSyncing: isSyncing ?? this.isSyncing,
  );
}

final class AreasFailure extends AreasState {
  final String message;
  const AreasFailure(this.message);
  @override
  List<Object?> get props => [message];
}