var str = '';
$('.stock_table tbody tr').each(function (idx, item) {
    var code = $(item).children('td').eq(1).children('a').html();
    
    if (/^\d+?$/.test(code)) {
        str += (str === '') ? code : ';' + code;
    }
});

console.log('var stockStr = "' + str + '"');
