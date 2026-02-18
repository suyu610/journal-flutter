import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/core/app_theme_colors.dart';
import 'package:journal/models/trip_card_model.dart';

class TripEditDialog extends StatefulWidget {
  final TripModel initialTrip;
  final Function(TripModel) onConfirm;

  const TripEditDialog({
    Key? key,
    required this.initialTrip,
    required this.onConfirm,
  }) : super(key: key);

  @override
  State<TripEditDialog> createState() => _TripEditDialogState();
}

class _TripEditDialogState extends State<TripEditDialog> {
  late TextEditingController _numberController;
  late TextEditingController _depCityController;
  late TextEditingController _arrCityController;
  late TextEditingController _depStationController;
  late TextEditingController _arrStationController;
  late TextEditingController _depDateController;
  late TextEditingController _depTimeController;
  late TextEditingController _arrTimeController;
  late TextEditingController _seatClassController;
  late TextEditingController _seatDetailController;

  @override
  void initState() {
    super.initState();
    _numberController = TextEditingController(text: widget.initialTrip.number);
    _depCityController =
        TextEditingController(text: widget.initialTrip.depCity);
    _arrCityController =
        TextEditingController(text: widget.initialTrip.arrCity);
    _depStationController =
        TextEditingController(text: widget.initialTrip.depStation ?? "");
    _arrStationController =
        TextEditingController(text: widget.initialTrip.arrStation ?? "");
    _depDateController =
        TextEditingController(text: widget.initialTrip.depDate);
    _depTimeController =
        TextEditingController(text: widget.initialTrip.depTime);
    _arrTimeController =
        TextEditingController(text: widget.initialTrip.arrTime);
    _seatClassController =
        TextEditingController(text: widget.initialTrip.seatClass ?? "");
    _seatDetailController =
        TextEditingController(text: widget.initialTrip.seatDetail ?? "");
  }

  @override
  void dispose() {
    _numberController.dispose();
    _depCityController.dispose();
    _arrCityController.dispose();
    _depStationController.dispose();
    _arrStationController.dispose();
    _depDateController.dispose();
    _depTimeController.dispose();
    _arrTimeController.dispose();
    _seatClassController.dispose();
    _seatDetailController.dispose();
    super.dispose();
  }

  void _onSave() {
    // 构造 JSON 数据以创建新的 TripModel
    Map<String, dynamic> json = {
      'type': widget.initialTrip.type,
      'status': widget.initialTrip.status,
      'transport': {
        'number': _numberController.text,
        'duration': widget.initialTrip.duration, // 暂时保留原时长
      },
      'departure': {
        'city': _depCityController.text,
        'station_airport': _depStationController.text,
        'time': _depTimeController.text,
        'date': _depDateController.text,
        'gate_platform': widget.initialTrip.depGate,
      },
      'arrival': {
        'city': _arrCityController.text,
        'station_airport': _arrStationController.text,
        'time': _arrTimeController.text,
        'day_diff': widget.initialTrip.dayDiff,
      },
      'finance': {
        'seat_class': _seatClassController.text,
        'seat_detail': _seatDetailController.text,
      },
      'meta': {
        'remark': widget.initialTrip.remark,
      }
    };

    try {
      print("Saving trip with JSON: $json");
      final newTrip = TripModel.fromJson(json);
      widget.onConfirm(newTrip);
      Get.back();
    } catch (e) {
      print("Error saving trip: $e");
      Get.snackbar("错误", "保存失败: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    var appColors = Theme.of(context).extension<AppThemeColors>()!;
    // 键盘弹出时，避免遮挡
    return Container(
      height: MediaQuery.of(context).size.height * 0.85, // 占屏幕 85% 高度
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      decoration: BoxDecoration(
        color: appColors.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // 标题栏
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("确认行程信息",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: appColors.primaryText)),
              IconButton(
                icon: Icon(Icons.close, color: appColors.secondaryText),
                onPressed: () => Get.back(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 表单区域
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("基本信息", appColors),
                  const SizedBox(height: 12),
                  _buildTextField("车次 / 航班号", _numberController, appColors,
                      icon: Icons.confirmation_number_outlined),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                          child: _buildTextField(
                              "出发城市", _depCityController, appColors,
                              icon: Icons.flight_takeoff)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _buildTextField(
                              "到达城市", _arrCityController, appColors,
                              icon: Icons.flight_land)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                          child: _buildTextField(
                              "出发站点", _depStationController, appColors)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _buildTextField(
                              "到达站点", _arrStationController, appColors)),
                    ],
                  ),

                  const SizedBox(height: 24),
                  _buildSectionTitle("时间信息", appColors),
                  const SizedBox(height: 12),
                  _buildTextField(
                      "出发日期 (YYYY-MM-DD)", _depDateController, appColors,
                      icon: Icons.calendar_today),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                          child: _buildTextField(
                              "出发时间", _depTimeController, appColors,
                              icon: Icons.access_time)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _buildTextField(
                              "到达时间", _arrTimeController, appColors,
                              icon: Icons.access_time_filled)),
                    ],
                  ),

                  const SizedBox(height: 24),
                  _buildSectionTitle("座位信息", appColors),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                          child: _buildTextField(
                              "席别", _seatClassController, appColors,
                              icon: Icons.chair)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _buildTextField(
                              "座位号", _seatDetailController, appColors,
                              icon: Icons.event_seat)),
                    ],
                  ),
                  const SizedBox(height: 40), // 底部留白
                ],
              ),
            ),
          ),

          // 底部按钮
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appColors.primaryText,
                    foregroundColor: appColors.cardBackground,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("确认添加",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, AppThemeColors appColors) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: appColors.secondaryText,
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, AppThemeColors appColors,
      {IconData? icon}) {
    return TextField(
      controller: controller,
      style: TextStyle(color: appColors.primaryText, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: appColors.secondaryText, fontSize: 13),
        prefixIcon: icon != null
            ? Icon(icon, color: appColors.secondaryText, size: 18)
            : null,
        filled: true,
        fillColor: appColors.backgroundColor.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        isDense: true,
      ),
    );
  }
}
