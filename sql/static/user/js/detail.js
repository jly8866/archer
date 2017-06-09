$(document).ready(function (){
  var status = $("#workflowDetail_status").text();
  if (status=="等待审核人审核"){
    setInterval("startRequest()",1000);
  }
});



function startRequest()
{
    $("#date").text((new Date()).toString());
    var workflowid = $("#workflowDetail_id").val();
    var sqls = sqlStrings();

    for(var i = 0; i < sqls.length; i++){
        var j = i + 1
        sql = sqls[i];
        $.ajax({
            type: "post",
            url: "/getOscPercent/",
            dataType: "json",
            data: {
                workflowid: workflowid,
                sqlString: sql,
            },
            complete: function () {
            },
            success: function (data) {
                if (data.status == 0) {
                    pct = data.data.percent;
                    $("div#sql_" + j).attr("style", "width: " + pct + "%");
                }
            },
            error: function () {
            }
        });
        }
}

function sqlStrings() {
    var sqls = new Array();
    $(".sqlString").each(function(){
      sqls.push($(this).text());
    });
    return sqls;
}
