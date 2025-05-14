class NeedRefreshData {
  final bool refreshProfile;
  final bool refreshCurrentActivity;
  final bool refreshActivityList;
  final bool refreshChartsList;

  const NeedRefreshData({ 
    this.refreshProfile = false,
    this.refreshCurrentActivity = false,
    this.refreshActivityList = false,
    this.refreshChartsList = false,
  });

  @override
  String toString() {
    return 'refreshProfile: $refreshProfile, refreshCurrentActivity: $refreshCurrentActivity, refreshActivityList: $refreshActivityList';
  }
}
