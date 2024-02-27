#pragma once
#include "afxdialogex.h"


// DispalyDialog 对话框

class DispalyDialog : public CDialog
{
	DECLARE_DYNAMIC(DispalyDialog)

public:
	DispalyDialog(CWnd* pParent = nullptr);   // 标准构造函数
	virtual ~DispalyDialog();
	unsigned int Blue[256], Green[256], Red[256];
	int w, h;

// 对话框数据
#ifdef AFX_DESIGN_TIME
	enum { IDD = IDD_ABOUTBOX };
#endif

protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV 支持

	DECLARE_MESSAGE_MAP()
public:
	afx_msg void OnPaint();
	//CString m_redXS;
	CString m_redXS;
	CString m_greenXS;
	CString m_blueXS;
	CString m_redPJHD;
	CString m_greenPJHD;
	CString m_bluePJHD;
	CString m_redZZHD;
	CString m_greenZZHD;
	CString m_blueZZHD;
};
