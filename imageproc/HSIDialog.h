﻿#pragma once


// HSIDialog 对话框

class HSIDialog : public CDialog
{
	DECLARE_DYNAMIC(HSIDialog)

public:
	HSIDialog(CWnd* pParent = nullptr);   // 标准构造函数
	virtual ~HSIDialog();

// 对话框数据
#ifdef AFX_DESIGN_TIME
	enum { IDD = IDD_DIALOG_HSI };
#endif

protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV 支持

	DECLARE_MESSAGE_MAP()
};
