#define _CRT_SECURE_NO_WARNINGS 1

#include"AboutDlg.h"

CAboutDlg::CAboutDlg() noexcept : CDialogEx(IDD_ABOUTBOX)
, TEXT1(_T(""))
{
}

void CAboutDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialogEx::DoDataExchange(pDX);
	DDX_Text(pDX, IDC_STATIC_TEXT1, TEXT1);

}

BEGIN_MESSAGE_MAP(CAboutDlg, CDialogEx)
END_MESSAGE_MAP()

// �������жԻ����Ӧ�ó�������
void CImgProcApp::OnAppAbout()
{
	CAboutDlg aboutDlg;
	aboutDlg.DoModal();
}
