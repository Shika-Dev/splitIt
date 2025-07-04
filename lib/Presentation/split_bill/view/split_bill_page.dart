import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';
import 'package:split_it/Presentation/homepage/view/homepage_view.dart';
import 'package:split_it/Presentation/split_bill/bloc/split_bill_bloc.dart';
import 'package:split_it/Presentation/summary_page/view/summary_page_view.dart';
import 'package:split_it/Resources/Theme/theme.dart';
import 'package:split_it/Resources/Widgets/button.dart';
import 'package:split_it/Resources/Widgets/separator.dart';
import 'package:split_it/Resources/utils/size_config.dart';

class SplitBillPage extends StatelessWidget {
  final String id;
  const SplitBillPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          GetIt.I<SplitBillBloc>()..add(InitSplitBillPage(id: id)),
      child: SplitBillPageView(),
    );
  }
}

class SplitBillPageView extends StatefulWidget {
  const SplitBillPageView({super.key});

  @override
  State<SplitBillPageView> createState() => _SplitBillPageViewState();
}

class _SplitBillPageViewState extends State<SplitBillPageView> {
  String? editingUserId;
  TextEditingController editingController = TextEditingController();

  @override
  void dispose() {
    editingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      body: SafeArea(
        child: BlocConsumer<SplitBillBloc, SplitBillState>(
          listener: (context, state) {
            if (state.status == SplitBillStatus.finish) {
              if (state.id == '') {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => HomePage()),
                  (route) => false,
                );
              } else {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => SummaryPage(id: state.id)),
                  (route) => false,
                );
              }
            }
          },
          builder: (context, state) {
            if (state.status == SplitBillStatus.loading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      'assets/lottie/loading.json',
                      fit: BoxFit.fitWidth,
                      width: SizeConfig.safeBlockHorizontal * 40,
                    ),
                  ],
                ),
              );
            }
            if (state.status == SplitBillStatus.failed) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      'assets/lottie/failed.json',
                      fit: BoxFit.fitWidth,
                      width: SizeConfig.safeBlockHorizontal * 30,
                    ),
                    VerticalSeparator(height: 3),
                    Text(
                      state.errorMessage ?? '',
                      style: CustomTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    state.model?.billModel.billName ?? '',
                    style: CustomTheme.h3,
                  ),
                  VerticalSeparator(height: 3),
                  SizedBox(
                    height: 84,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (_, index) {
                        final userCount = state.model?.users.length ?? 0;
                        if (index < userCount) {
                          return getUserWidget(state, index);
                        }
                        return getAddUserWidget();
                      },
                      separatorBuilder: (_, __) =>
                          HorizontalSeparator(width: 3),
                      itemCount: (state.model?.users.length ?? 0) + 1,
                    ),
                  ),
                  VerticalSeparator(height: 3),
                  Expanded(
                    child: ListView.separated(
                      itemBuilder: (_, index) {
                        final itemCount =
                            state.model?.billModel.items?.length ?? 0;
                        if (index < itemCount) {
                          return getBillListWidget(state, index);
                        }
                        // Last item: summary rows
                        return Column(
                          children: [
                            VerticalSeparator(height: 1),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Subtotal', style: CustomTheme.bodySmall),
                                Text(
                                  state.model?.billModel.subtotal.toString() ??
                                      '',
                                  style: CustomTheme.bodySmall,
                                ),
                              ],
                            ),
                            VerticalSeparator(height: 1),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Service Charge',
                                  style: CustomTheme.bodySmall,
                                ),
                                Text(
                                  state.model?.billModel.service.toString() ??
                                      '',
                                  style: CustomTheme.bodySmall,
                                ),
                              ],
                            ),
                            VerticalSeparator(height: 1),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Tax', style: CustomTheme.bodySmall),
                                Text(
                                  state.model?.billModel.tax.toString() ?? '',
                                  style: CustomTheme.bodySmall,
                                ),
                              ],
                            ),
                            VerticalSeparator(height: 1),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Discount', style: CustomTheme.bodySmall),
                                Text(
                                  state.model?.billModel.discount.toString() ??
                                      '',
                                  style: CustomTheme.bodySmall,
                                ),
                              ],
                            ),
                            VerticalSeparator(height: 1),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Total', style: CustomTheme.bodySmall),
                                Text(
                                  state.model?.billModel.total.toString() ?? '',
                                  style: CustomTheme.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                      separatorBuilder: (_, __) => VerticalSeparator(height: 1),
                      itemCount:
                          (state.model?.billModel.items?.length ?? 0) + 1,
                    ),
                  ),
                  VerticalSeparator(height: 1),
                  Row(
                    children: [
                      Flexible(
                        child: SplitBillButton(
                          onPressed: () {
                            context.read<SplitBillBloc>().add(
                              SplitBillPageDispose(),
                            );
                          },
                          label: 'Cancel',
                        ),
                      ),
                      HorizontalSeparator(width: 3),
                      Flexible(
                        child: SplitBillButton(
                          onPressed: () {
                            context.read<SplitBillBloc>().add(
                              CalculateSummary(),
                            );
                          },
                          label: 'Calculate',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget getUserWidget(SplitBillState state, int index) {
    final user = state.model?.users[index];
    final isEditing = user != null && user.id == editingUserId;
    return GestureDetector(
      onTap: () => context.read<SplitBillBloc>().add(
        UpdateSelectedUser(userId: user?.id ?? ''),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CustomTheme.primaryColor,
              border: state.selectedUser?.id == user?.id
                  ? Border.all(color: CustomTheme.strokeColor, width: 1)
                  : null,
            ),
            child: Center(
              child: Icon(Icons.person, color: CustomTheme.textColor, size: 30),
            ),
          ),
          SizedBox(height: 3),
          isEditing
              ? IntrinsicWidth(
                  child: TextFormField(
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      counterText: '',
                    ),
                    controller: editingController,
                    autofocus: true,
                    maxLength: 10,
                    onEditingComplete: () {
                      context.read<SplitBillBloc>().add(
                        UpdateUserName(
                          userId: user.id,
                          name: editingController.text,
                        ),
                      );
                      setState(() {
                        editingUserId = null;
                      });
                    },
                    style: CustomTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                )
              : GestureDetector(
                  onTap: () {
                    setState(() {
                      editingUserId = user!.id;
                      editingController.text = user.name;
                    });
                  },
                  child: Text(user?.name ?? '', style: CustomTheme.bodySmall),
                ),
        ],
      ),
    );
  }

  Column getAddUserWidget() {
    return Column(
      children: [
        InkWell(
          onTap: () {
            final bloc = context.read<SplitBillBloc>();
            bloc.add(AddUserToSplitBill(name: ''));
            // Wait for the bloc to update, then set editingUserId to the last user's id
            Future.delayed(Duration(milliseconds: 100), () {
              final state = bloc.state;
              final users = state.model?.users;
              if (users != null && users.isNotEmpty) {
                setState(() {
                  editingUserId = users.last.id;
                  editingController.text = '';
                });
              }
            });
          },
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CustomTheme.primaryColor,
            ),
            child: Center(
              child: Icon(Icons.add, color: CustomTheme.textColor, size: 30),
            ),
          ),
        ),
      ],
    );
  }

  Widget getBillListWidget(SplitBillState state, int index) {
    return InkWell(
      onTap: () {
        final selectedUser = state.selectedUser;
        if (selectedUser != null) {
          context.read<SplitBillBloc>().add(
            AssignUserToBillItem(itemIndex: index, userId: selectedUser.id),
          );
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                state.model?.billModel.items?[index].name ?? '',
                style: CustomTheme.bodySmall,
              ),
              Text(
                state.model?.billModel.items?[index].price.toString() ?? '',
                style: CustomTheme.bodySmall,
              ),
            ],
          ),
          VerticalSeparator(height: 1),
          Text(
            'x ${state.model?.billModel.items?[index].quantity ?? 0}',
            style: CustomTheme.bodySmall,
          ),
          VerticalSeparator(height: 1),
          Visibility(
            visible:
                (state.model?.billModel.items?[index].userIds.length ?? 0) > 0,
            child: SizedBox(
              height: 53,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, i) => getAsignedUserWidget(
                  state,
                  state.model?.billModel.items?[index].userIds[i] ?? '',
                ),
                separatorBuilder: (_, __) => HorizontalSeparator(width: 1),
                itemCount:
                    state.model?.billModel.items?[index].userIds.length ?? 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getAsignedUserWidget(SplitBillState state, String userId) {
    final user = state.model?.users.firstWhere((e) => e.id == userId);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: CustomTheme.primaryColor,
          ),
          child: Center(
            child: Icon(Icons.person, color: CustomTheme.textColor, size: 20),
          ),
        ),
        SizedBox(height: 3),
        Text(user?.name ?? '', style: CustomTheme.bodySmall),
      ],
    );
  }
}
