/*
// 曜日の配列
var daysOfTheWeek = ['日', '月', '火', '水', '木', '金', '土'];
var currentRowId;
var attendanceId;

$(document).ready(function() {
  // 残業申請ボタンにイベントリスナーを追加
  $('a[data-toggle="modal"][data-target="#overtimeModal"]').each(function() {
    $(this).click(function() {
      currentRowId = $(this).attr('data-row-id');
      attendanceId = $(this).attr('data-id');
      var dateStr = $(this).attr('data-date');

      // 日付のバリデーション
      if (!Date.parse(dateStr)) {
        console.error('Invalid date format:', dateStr);
        return;
      }

      // モーダルの中の日付を更新
      $('#overtimeModal tbody tr td:first-child').text(dateStr);

      // モーダルの中の曜日を更新
      var dateObj = new Date(dateStr);
      var dayOfWeek = dateObj.getDay();
      $('#modal_day_of_week').text(daysOfTheWeek[dayOfWeek]);
      
      // モーダルのフォームのアクションを更新
      const actionUrl = `/users/${window.currentUserId}/attendances/${attendanceId}/update_overtime`;
      $('#overtimeModal form').attr('action', actionUrl);
    });
  });

  // モーダルが表示されたときに発火
  $('#overtimeModal').on('show.bs.modal', function(event) {
    const button = $(event.relatedTarget);
    const rowId = button.data('row-id');
    const modal = $(this);
    modal.find('.modal-body #some-span').text(rowId);
  });

  // 終了予定時間をテーブルに反映する関数
  function reflectOvertimeToTable() {
    console.log("Current Row ID:", currentRowId);
    var endTime = $('#end_time').val();
    if (!endTime) {
      alert('終了予定時間が入力されていません。');
      return false;
    }

    var targetRow = $('#' + currentRowId);
    targetRow.find('.end-time-cell').text(endTime);

    return true;
  }

  // 日付を取得
  const today = new Date();
  const month = (today.getMonth() + 1); // 月を取得
  const day = today.getDate(); // 日を取得

  // 曜日を取得
  const weekday = daysOfTheWeek[today.getDay()];

  // 対応するHTML要素に値を設定
  $("#modal_date").text(`${month}/${day}`);
  $("#modal_day_of_week").text(weekday);

  // その他の機能を初期化
  var supervisorSelect = $('#supervisor');
  var submitButton = $('#overtimeModal .modal-footer .btn');

  submitButton.click(function(e) {
    debugger; 
    // 指示者の選択をチェック
    if (!supervisorSelect.val()) {
      e.preventDefault();
      alert('指示者を選択してください。');
      return;
    }

    if (!reflectOvertimeToTable()) {
      e.preventDefault();
    }
  });
});
*/
