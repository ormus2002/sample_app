
var MaxLen = 140;

function onTypeChar() {
 var elem=$("#micropost_content").val();
 var remaining_chars = (MaxLen) - elem.length;
 $("#char_count_out_id").html(remaining_chars);
// elem.focus();
}

