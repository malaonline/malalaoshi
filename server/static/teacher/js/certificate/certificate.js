/**
 * Created by liumengjun on 1/15/16.
 */
$(function(){
    var getObjectURL = function(file) {
      var url = null;
      if (window.createObjectURL != undefined) {
        url = window.createObjectURL(file);
      } else if (window.URL != undefined) {
        url = window.URL.createObjectURL(file);
      } else if (window.webkitURL != undefined) {
        url = window.webkitURL.createObjectURL(file);
      }
      return url;
    };
    // input file changed event
    $('input[type=file]').change(function(e){
        var ele = e.target, $ele = $(ele);
        var $uploadBox = $ele.closest(".img-upload-box");
        var imgType = ["gif", "jpeg", "jpg", "bmp", "png"];
        var flag = validImgFile();
        if (!flag) {
          return false;
        }
        var imtUrl = getObjectURL(ele.files[0]);
        var $previewBox = $uploadBox.find(".img-preview-box");
        $previewBox.find('img').attr("src", imtUrl);
        $previewBox.show();
        return true;

        // valid image properties
        function validImgFile() {
          if (!ele.value || !ele.files) {
            return false;
          }
          //验证上传文件格式是否正确
          if (!RegExp("\.(" + imgType.join("|") + ")$", "i").test(ele.value.toLowerCase())) {
            $uploadBox.addClass('has-error');
            $uploadBox.find('.help-block').text('选择图片类型错误');
            this.value = "";
            return false;
          }
          return true;
        }
    });
    // 工具提示
    $(function () {
        $('[data-toggle="tooltip"]').tooltip({'html':true})
    });
    // 其他认证列表,[编辑][删除]按钮
    $("#otherCertsList [data-action=edit-cert]").click(function (e){
        var $row = $(this).closest('.row');
        var certId = $row.attr('certId'), certName = $row.find('.cert-name').text(), certImgUrl = $row.find('.cert-img-view img')[0].src;
        var $form = $('#certEditForm');
        $form.find('input[name=id]').val(certId);
        $form.find('input[name=name]').val(certName);
        $form.find('.img-box img')[0].src = certImgUrl;
    });
    var defaultErrMsg = '请求失败,请稍后重试,或联系管理员!';
    $("#otherCertsList [data-action=delete-cert]").click(function (e){
        var decided = confirm('确定要删除这个证书吗?');
        if (!decided) return false;
        var $row = $(this).closest('.row'), certId = $row.attr('certId');
        if (certId) {
            var params = {'action': 'delete', 'certId': certId};
            malaAjaxPost( "/teacher/certificate/others/", params, function( result ) {
                if (result) {
                    if (result.ok) {
                        $row.remove();
                    } else {
                        alert(result.msg);
                    }
                    return;
                }
                alert(defaultErrMsg);
            }, 'json', function(jqXHR, errorType, errorDesc){
                var errMsg = errorDesc?('['+errorDesc+'] '):'';
                alert(errMsg+defaultErrMsg);
            });
        }
    });
    //form取消操作
    $("#certEditForm [data-action=cancel]").click(function(e){
        location.href = certOverviewPageUrl;
    });
    var hasImg = function($editBox) {
        var hasImg = !!$editBox.find('.img-box img').attr('src');
        var hasPreImg = !!$editBox.find('.img-preview-box img').attr('src');
        return hasImg || hasPreImg;
    };
    //form保存操作
    $('#certEditForm').submit(function(e){
        return false;
    });
    $("#certEditForm [data-action=save]").click(function(e){
        var $form = $('#certEditForm');
        var isOtherCertPage = $form.find('input[name=id]')[0]; // 是否是其他认证页面
        var isIdCertPage = $form.find('input[name=id_num]')[0]; // 是否是身份证认证页面
        if (isIdCertPage) {
            if (!$.trim($('#id_num').val())) {
                return alert("身份证号不能为空");
            }
            if (!hasImg($form.find('.img-upload-box[imgName="idHeldImg"]'))) {
                return alert("手持身份证照片不能为空");
            }
            if (!hasImg($form.find('.img-upload-box[imgName="idFrontImg"]'))) {
                return alert("身份证正面图片不能为空");
            }
        } else {
            if (!$.trim($('#name').val())) {
                return alert("证书名称不能为空");
            }
            if ($('#name').val().length>15) {
                return alert("证书名称不能超过15个字");
            }
            if (!hasImg($form.find('.img-upload-box'))) {
                return alert("没有证书照片");
            }
        }
        showLoading();
        $form.ajaxSubmit({
            data: {'format': 'json'},
            dataType: 'json',
            success: function(result){
                if (result) {
                    if (result.ok) {
                        if (isOtherCertPage) {
                            location.reload();
                        } else {
                            alert('保存成功');
                            if (nextPage) {
                                location.href = nextPage;
                                return;
                            }
                            if (isIdCertPage) {
                                var $idHeldImgBox = $form.find('.img-upload-box[imgName=idHeldImg] .img-box'),
                                    $idFrontImgBox = $form.find('.img-upload-box[imgName=idFrontImg] .img-box');
                                $idHeldImgBox.find('img').attr('src', result.idHeldUrl);
                                $idHeldImgBox.show();
                                $idFrontImgBox.find('img').attr('src', result.idFrontUrl);
                                $idFrontImgBox.show();
                            } else {
                                $form.find('.img-box img').attr('src', result.cert_img_url);
                                $form.find('.img-box').show();
                            }
                            $form.find('.img-preview-box').hide();
                        }
                    } else {
                        alert(result.msg);
                    }
                } else {
                    alert(defaultErrMsg);
                }
                hideLoading();
            },
            error: function(jqXHR, errorType, errorDesc){
                var errMsg = errorType?('['+errorType+(errorDesc?(':'+errorDesc):'')+']'):'';
                alert(errMsg+defaultErrMsg);
                hideLoading();
            }
        });
    });
});
