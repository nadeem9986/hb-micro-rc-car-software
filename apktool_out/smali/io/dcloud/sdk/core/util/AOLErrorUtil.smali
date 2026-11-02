.class public Lio/dcloud/sdk/core/util/AOLErrorUtil;
.super Ljava/lang/Object;
.source "SourceFile"


# direct methods
.method public constructor <init>()V
    .locals 0

    .line 1
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public static getErrorMsg(I)Ljava/lang/String;
    .locals 3

    .line 1
    invoke-static {}, Lio/dcloud/p/r0;->d()Lio/dcloud/p/r0;

    move-result-object v0

    if-eqz v0, :cond_5

    invoke-static {}, Lio/dcloud/p/r0;->d()Lio/dcloud/p/r0;

    move-result-object v0

    invoke-virtual {v0}, Lio/dcloud/p/r0;->c()Landroid/content/Context;

    move-result-object v0

    if-nez v0, :cond_0

    goto/16 :goto_0

    .line 7
    :cond_0
    invoke-static {}, Lio/dcloud/p/r0;->d()Lio/dcloud/p/r0;

    move-result-object v0

    invoke-virtual {v0}, Lio/dcloud/p/r0;->c()Landroid/content/Context;

    move-result-object v0

    const/16 v1, -0x13ec

    if-eq p0, v1, :cond_4

    packed-switch p0, :pswitch_data_0

    const-string v1, ""

    packed-switch p0, :pswitch_data_1

    const/16 v2, -0xfa2

    if-eq p0, v2, :cond_3

    const/16 v2, -0xfa1

    if-eq p0, v2, :cond_2

    const/16 v2, -0x25b

    if-eq p0, v2, :cond_1

    packed-switch p0, :pswitch_data_2

    packed-switch p0, :pswitch_data_3

    return-object v1

    .line 118
    :pswitch_0
    sget p0, Lio/dcloud/base/R$string;->dcloud_ad_error_code_5011:I

    invoke-virtual {v0, p0}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object p0

    return-object p0

    .line 120
    :pswitch_1
    sget p0, Lio/dcloud/base/R$string;->dcloud_ad_error_code_5012:I

    invoke-virtual {v0, p0}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object p0

    return-object p0

    .line 122
    :pswitch_2
    sget p0, Lio/dcloud/base/R$string;->dcloud_ad_error_code_5013:I

    invoke-virtual {v0, p0}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object p0

    return-object p0

    .line 124
    :pswitch_3
    sget p0, Lio/dcloud/base/R$string;->dcloud_ad_error_code_5014:I

    invoke-virtual {v0, p0}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object p0

    return-object p0

    .line 126
    :pswitch_4
    sget p0, Lio/dcloud/base/R$string;->dcloud_ad_error_code_5015:I

    invoke-virtual {v0, p0}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object p0

    return-object p0

    .line 128
    :pswitch_5
    sget p0, Lio/dcloud/base/R$string;->dcloud_ad_error_code_5016:I

    invoke-virtual {v0, p0}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object p0

    return-object p0

    .line 130
    :pswitch_6
    sget p0, Lio/dcloud/base/R$string;->dcloud_ad_error_code_5017:I

    invoke-virtual {v0, p0}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object p0

    return-object p0

    .line 132
    :pswitch_7
    sget p0, Lio/dcloud/base/R$string;->dcloud_ad_error_code_5018:I

    invoke-virtual {v0, p0}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object p0

    return-object p0

    .line 134
    :pswitch_8
    sget p0, Lio/dcloud/base/R$string;->dcloud_ad_error_code_5019:I

    invoke-virtual {v0, p0}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object p0

    return-object p0

    .line 136
    :pswitch_9
    sget p0, Lio/dcloud/base/R$string;->dcloud_ad_error_code_5020:I

    invoke-virtual {v0, p0}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object p0

    return-object p0

    .line 138
    :pswitch_a
    sget p0, Lio/dcloud/base/R$string;->dcloud_ad_error_code_5021:I

    invoke-virtual {v0, p0}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object p0

    return-object p0

    .line 140
    :pswitch_b
    sget p0, Lio/dcloud/base/R$string;->dcloud_ad_error_code_5022:I

    invoke-virtual {v0, p0}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object p0

    return-object p0

    :pswitch_c
    return-object v1

    .line 102
    :pswitch_d
    sget p0, Lio/dcloud/base/R$string;->dcloud_ad_error_code_5001:I

    invoke-virtual {v0, p0}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object p0

    return-object p0

    .line 104
    :pswitch_e
    sget p0, Lio/dcloud/base/R$string;->dcloud_ad_error_code_5002:I

    invoke-virtual {v0, p0}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object p0

    return-object p0

    .line 106
    :pswitch_f
    sget p0, Lio/dcloud/base/R$string;->dcloud_ad_error_code_5003:I

    invoke-virtual {v0, p0}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object p0

    return-object p0

    .line 108
    :pswitch_10
    sget p0, Lio/dcloud/base/R$string;->dcloud_ad_error_code_5004:I

    invoke-virtual {v0, p0}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object p0

    return-object p0

    .line 110
    :pswitch_11
    sget p0, Lio/dcloud/base/R$string;->dcloud_ad_error_code_5005:I

    invoke-virtual {v0, p0}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object p0

    return-object p0

    .line 112
    :pswitch_12
    sget p0, Lio/dcloud/base/R$string;->dcloud_ad_error_code_5006:I

    invoke-virtual {v0, p0}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object p0

    return-object p0

    .line 114
    :pswitch_13
    sget p0, Lio/dcloud/base/R$string;->dcloud_ad_error_code_5007:I

    invoke-virtual {v0, p0}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object p0

    return-object p0

    .line 116
    :pswitch_14
    sget p0, Lio/dcloud/base/R$string;->dcloud_ad_error_code_5008:I

    invoke-virtual {v0, p0}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object p0

    return-object p0

    .line 81
    :pswitch_15
    const-string/jumbo p0, "Ad initialization error"

    return-object p0

    .line 83
    :pswitch_16
    const-string/jumbo p0, "WeChat is not installed on this device"

    return-object p0

    .line 85
    :pswitch_17
    const-string/jumbo p0, "The current version of WeChat cannot run mini programs"

    return-object p0

    .line 87
    :pswitch_18
    const-string/jumbo p0, "Failed to get ad configuration data"

    return-object p0

    .line 89
    :pswitch_19
    const-string/jumbo p0, "Ad request failed, please try again later"

    return-object p0

    :pswitch_1a
    return-object v1

    .line 91
    :pswitch_1b
    sget p0, Lio/dcloud/base/R$string;->dcloud_ad_error_code_200000:I

    invoke-virtual {v0, p0}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object p0

    return-object p0

    .line 93
    :cond_1
    sget p0, Lio/dcloud/base/R$string;->dcloud_ad_error_code_603:I

    invoke-virtual {v0, p0}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object p0

    return-object p0

    .line 97
    :cond_2
    const-string p0, "init fail"

    return-object p0

    .line 99
    :cond_3
    const-string p0, "exception when load"

    return-object p0

    .line 142
    :cond_4
    sget p0, Lio/dcloud/base/R$string;->dcloud_ad_error_code_5100:I

    invoke-virtual {v0, p0}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object p0

    return-object p0

    .line 143
    :cond_5
    :goto_0
    invoke-static {}, Ljava/util/Locale;->getDefault()Ljava/util/Locale;

    move-result-object p0

    invoke-virtual {p0}, Ljava/util/Locale;->getCountry()Ljava/lang/String;

    move-result-object p0

    const-string/jumbo v0, "zh"

    invoke-virtual {v0, p0}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    move-result p0

    if-eqz p0, :cond_6

    .line 144
    const-string/jumbo p0, "Ad is not initialized or its init info is empty"

    return-object p0

    .line 146
    :cond_6
    const-string p0, "Please init first"

    return-object p0

    :pswitch_data_0
    .packed-switch -0x139e
        :pswitch_b
        :pswitch_a
        :pswitch_9
        :pswitch_8
        :pswitch_7
        :pswitch_6
        :pswitch_5
        :pswitch_4
        :pswitch_3
        :pswitch_2
        :pswitch_1
        :pswitch_0
    .end packed-switch

    :pswitch_data_1
    .packed-switch -0x1390
        :pswitch_14
        :pswitch_13
        :pswitch_12
        :pswitch_11
        :pswitch_10
        :pswitch_f
        :pswitch_e
        :pswitch_d
        :pswitch_c
    .end packed-switch

    :pswitch_data_2
    .packed-switch 0x30d40
        :pswitch_1b
        :pswitch_1a
    .end packed-switch

    :pswitch_data_3
    .packed-switch -0xc73d
        :pswitch_19
        :pswitch_18
        :pswitch_17
        :pswitch_16
        :pswitch_15
    .end packed-switch
.end method
