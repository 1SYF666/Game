#pragma once
#include "pch.h"
#include "framework.h"
#include "afxwinappex.h"
#include "afxdialogex.h"
#include "ImgProc.h"
#include "MainFrm.h"

#include "ChildFrm.h"
#include "ImgProcDoc.h"
#include "ImgProcView.h"

class CAboutDlg : public CDialogEx
{
public:
	CAboutDlg() noexcept;

	// �Ի�������
#ifdef AFX_DESIGN_TIME
	enum { IDD = IDD_ABOUTBOX };
#endif

protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV ֧��

// ʵ��
protected:
	DECLARE_MESSAGE_MAP()
public:

	CString TEXT1;

};
