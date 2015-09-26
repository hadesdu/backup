if (!window.stockStr) {
    throw 'stockStr is needed';
}

var stocksArr = [];
var thsStocks = [];

$.ajax('http://xueqiu.com/v4/stock/portfolio/stocks.json?size=1000&tuid=1883623134&category=2&type=1').then(
    function (data) {
        stocks = data.stocks

        stocks.forEach(function (item, idx) {
            stocksArr.push(item.code);
        });

        var needNotice = [];
        var needDelete = [];

        stockStr.split(';').forEach(function (item, idx) {
            var code;

            if (/^6/.test(item)) {
                code = 'SH' + item;
            }
            else if (/^(00|30)/.test(item)) {
                code = 'SZ' + item;
            }
            else {
                return ;
            }
            
            thsStocks.push(code);

            if (stocksArr.indexOf(code) === -1) {
                needNotice.push(code);
            }
        });

        stocksArr.forEach(function (item, idx) {
            if (thsStocks.indexOf(item) === -1) {
                needDelete.push(item);
            }
        });

        doAll(needNotice, needDelete).then(
            function () {
                orderStocks();
            }
        );
    }
);

function doAll(needNotice, needDelete) {
    var deferred = new $.Deferred();

    var deferreds = [];

    needNotice.forEach(function (item, idx) {
        deferreds.push(notice(item));
    });

    needDelete.forEach(function (item, idx) {
        deferreds.push(delStock(item));
    });

    $.when.apply($, deferreds).then(
        function () {
            deferred.resolve();
        }
    );

    return deferred.promise();
}

function notice(code) {
    var deferred = new $.Deferred();

    $.ajax(
        'http://xueqiu.com/stock/portfolio/addstock.json',
        {
            method: 'POST',
            data: {
                isnotice: 1,
                code: code
            }
        }
    ).then(
        function () {
            console.log('notice ' + code);
            stocksArr.push(code);
            deferred.resolve();
        },
        function () {
            console.log('failed to notice ' + code);
            deferred.resolve();
        }
    );

    return deferred.promise();
}

function delStock(code) {
    var deferred = new $.Deferred();

    $.ajax(
        'http://xueqiu.com/stock/portfolio/delstock.json',
        {
            data: {
                code: code
            }
        }
    ).then(
        function () {
            console.log('delete stock ' + code);
            stocksArr.splice(stocksArr.indexOf(code), 1);
            deferred.resolve();
        },
        function () {
            deferred.resolve();
        }
    );

    return deferred.promise();
}

function orderStocks(stocks) {
    var arr = [];

    thsStocks.forEach(function (item, idx) {
        if (stocksArr.indexOf(item) !== -1) {
            arr.push(item);
        }
    });

    $.ajax(
        'http://xueqiu.com/v4/stock/portfolio/modifystocks.json',
        {
            method: 'POST',
            data: {
                pid: '-1',
                type: '1',
                stocks: arr.join(',')
            }
        }
    ).then(
        function () {
            console.log('order done, orders: ' + arr.join(','));
        },
        function () {
            console.log('order failed');
        }
    );
}
