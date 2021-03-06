/**
 * Created by liumengjun on 3/23/16.
 */
$(function(){
    //alert("coupon list");
    var hours = sessionStorage.hours;
    var price = sessionStorage.chosen_price;
    var chosen_coupon_id = '';

    var $alertDialog = $('#alertDialog');
    var $alertDialogBody = $("#alertDialogBody");
    var showAlertDialog = function(msg) {
        $alertDialogBody.html(msg);
        $alertDialog.show();
        $alertDialog.find('.weui_dialog').one('click', function () {
            $alertDialog.hide();
        });
    };

    var pre_chosen_coupon_id = $("#preChosenCoupon").val();
    if (sessionStorage.chosen_coupon_id) {
        pre_chosen_coupon_id = sessionStorage.chosen_coupon_id;
    }
    var $coupons = $('.coupon');
    if (pre_chosen_coupon_id) {
        sessionStorage.chosen_coupon_id = '';
        $coupons.each(function () {
            var $this = $(this), cpid = $this.attr('couponId');
            if (cpid == pre_chosen_coupon_id) {
                var min_cost = parseInt($this.find('.min_cost').text());
                if (hours*price<min_cost*100){
                    return false;
                }
                $this.addClass('chosen');
                chosen_coupon_id = pre_chosen_coupon_id;
                sessionStorage.chosen_coupon_id = chosen_coupon_id;
                sessionStorage.chosen_coupon_amount = $this.find('.amount').text();
                sessionStorage.chosen_coupon_min_cost = min_cost;
                return false;
            }
        });
    }
    if (!chosen_coupon_id) { // 自动选择一个
        var _max_amount = 0, $_chosen;
        $coupons.each(function () {
            var $this = $(this), cpid = $this.attr('couponId');
            var min_cost = parseInt($this.find('.min_cost').text());
            if (hours*price<min_cost*100){
                return;
            }
            var cur_amount = parseInt($this.find('.amount').text());
            if (_max_amount < cur_amount) {
                _max_amount = cur_amount;
                $_chosen = $this;
                chosen_coupon_id = cpid;
                sessionStorage.chosen_coupon_id = chosen_coupon_id;
                sessionStorage.chosen_coupon_amount = cur_amount;
                sessionStorage.chosen_coupon_min_cost = min_cost;
            }
        });
        $_chosen && $_chosen.addClass('chosen');
    }

    $coupons.click(function(){
        /// NOTE: 更新discount不在这里做, 在后面的updateCost()方法里
        if (hours==0) {
            showAlertDialog('请先选择上课时间');
            return;
        }
        var $this = $(this), cpid = $this.attr('couponId');
        if ($this.hasClass('used') || $this.hasClass('expired')) {
            return;
        }
        if (cpid==chosen_coupon_id) {
            chosen_coupon_id = '';
            sessionStorage.chosen_coupon_id = chosen_coupon_id;
            sessionStorage.chosen_coupon_amount = 0;
            sessionStorage.chosen_coupon_min_cost = '';
            $this.removeClass('chosen');
            return;
        }
        var min_cost = parseInt($this.find('.min_cost').text());
        if (hours*price<min_cost*100){
            showAlertDialog('订单金额数不足');
            return;
        }
        // choose this one
        chosen_coupon_id = cpid;
        sessionStorage.chosen_coupon_id = chosen_coupon_id;
        sessionStorage.chosen_coupon_min_cost = min_cost;
        $coupons.each(function () {
            var _$this = $(this), _cpid = _$this.attr('couponId');
            if (_cpid == chosen_coupon_id) {
                _$this.addClass('chosen');
                sessionStorage.chosen_coupon_amount = $this.find('.amount').text();
            } else {
                _$this.removeClass('chosen');
            }
        });
    });
});
