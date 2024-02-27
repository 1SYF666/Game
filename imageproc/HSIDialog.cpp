// HSIDialog.cpp: 实现文件
//

#include "pch.h"
#include "ImgProc.h"
#include "HSIDialog.h"
#include "afxdialogex.h"


// HSIDialog 对话框

IMPLEMENT_DYNAMIC(HSIDialog, CDialog)

HSIDialog::HSIDialog(CWnd* pParent /*=nullptr*/)
	: CDialog(IDD_DIALOG_HSI, pParent)
{

}

HSIDialog::~HSIDialog()
{
}

void HSIDialog::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
}


BEGIN_MESSAGE_MAP(HSIDialog, CDialog)
END_MESSAGE_MAP()


// HSIDialog 消息处理程序
