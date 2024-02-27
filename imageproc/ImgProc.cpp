
// ImgProc.cpp: 定义应用程序的类行为。
//

#include "pch.h"
#include "framework.h"
#include "afxwinappex.h"
#include "afxdialogex.h"
#include "ImgProc.h"
#include "MainFrm.h"

#include "ChildFrm.h"
#include "ImgProcDoc.h"
#include "ImgProcView.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif


// CImgProcApp

BEGIN_MESSAGE_MAP(CImgProcApp, CWinApp)
	ON_COMMAND(ID_APP_ABOUT, &CImgProcApp::OnAppAbout)
	// 基于文件的标准文档命令
	ON_COMMAND(ID_FILE_NEW, &CWinApp::OnFileNew)
	ON_COMMAND(ID_FILE_OPEN, &CWinApp::OnFileOpen)
	// 标准打印设置命令
	ON_COMMAND(ID_FILE_PRINT_SETUP, &CWinApp::OnFilePrintSetup)
END_MESSAGE_MAP()


// CImgProcApp 构造

CImgProcApp::CImgProcApp() noexcept
{

	// 支持重新启动管理器
	m_dwRestartManagerSupportFlags = AFX_RESTART_MANAGER_SUPPORT_ALL_ASPECTS;
#ifdef _MANAGED
	// 如果应用程序是利用公共语言运行时支持(/clr)构建的，则: 
	//     1) 必须有此附加设置，“重新启动管理器”支持才能正常工作。
	//     2) 在您的项目中，您必须按照生成顺序向 System.Windows.Forms 添加引用。
	System::Windows::Forms::Application::SetUnhandledExceptionMode(System::Windows::Forms::UnhandledExceptionMode::ThrowException);
#endif

	// TODO: 将以下应用程序 ID 字符串替换为唯一的 ID 字符串；建议的字符串格式
	//为 CompanyName.ProductName.SubProduct.VersionInformation
	SetAppID(_T("ImgProc.AppID.NoVersion"));

	// TODO:  在此处添加构造代码，
	// 将所有重要的初始化放置在 InitInstance 中
}

// 唯一的 CImgProcApp 对象

CImgProcApp theApp;


// CImgProcApp 初始化

BOOL CImgProcApp::InitInstance()
{
	// 如果一个运行在 Windows XP 上的应用程序清单指定要
	// 使用 ComCtl32.dll 版本 6 或更高版本来启用可视化方式，
	//则需要 InitCommonControlsEx()。  否则，将无法创建窗口。
	INITCOMMONCONTROLSEX InitCtrls;
	InitCtrls.dwSize = sizeof(InitCtrls);
	// 将它设置为包括所有要在应用程序中使用的
	// 公共控件类。
	InitCtrls.dwICC = ICC_WIN95_CLASSES;
	InitCommonControlsEx(&InitCtrls);

	CWinApp::InitInstance();


	// 初始化 OLE 库
	if (!AfxOleInit())
	{
		AfxMessageBox(IDP_OLE_INIT_FAILED);
		return FALSE;
	}

	AfxEnableControlContainer();

	EnableTaskbarInteraction(FALSE);

	// 使用 RichEdit 控件需要 AfxInitRichEdit2()
	// AfxInitRichEdit2();

	// 标准初始化
	// 如果未使用这些功能并希望减小
	// 最终可执行文件的大小，则应移除下列
	// 不需要的特定初始化例程
	// 更改用于存储设置的注册表项
	// TODO: 应适当修改该字符串，
	// 例如修改为公司或组织名
	SetRegistryKey(_T("应用程序向导生成的本地应用程序"));
	LoadStdProfileSettings(4);  // 加载标准 INI 文件选项(包括 MRU)


	// 注册应用程序的文档模板。  文档模板
	// 将用作文档、框架窗口和视图之间的连接
	CMultiDocTemplate* pDocTemplate;
	pDocTemplate = new CMultiDocTemplate(IDR_ImgProcTYPE,
		RUNTIME_CLASS(CImgProcDoc),
		RUNTIME_CLASS(CChildFrame), // 自定义 MDI 子框架
		RUNTIME_CLASS(CImgProcView));
	if (!pDocTemplate)
		return FALSE;
	AddDocTemplate(pDocTemplate);

	// 创建主 MDI 框架窗口
	CMainFrame* pMainFrame = new CMainFrame;
	if (!pMainFrame || !pMainFrame->LoadFrame(IDR_MAINFRAME))
	{
		delete pMainFrame;
		return FALSE;
	}
	m_pMainWnd = pMainFrame;


	// 分析标准 shell 命令、DDE、打开文件操作的命令行
	CCommandLineInfo cmdInfo;                          
	ParseCommandLine(cmdInfo);

	//**************2023/10/20 22:56*************** 
	//CCommandLineInfo是一个对MFC程序创建的时候通过调用命令进行初始化的类
	//这个类的一个方法FileNothing就是说不要创建文件
	//m_nShellCommand则是函数的一个参数，对应的命令是FileNew也就是打开新文件。
	/*
	  插入的代码的意思就是创建一个CCommandLineInfo对象，
	  然后传递给ParseCommandLine函数，在ParseCommandLine函数中将m_nShellCommand设置为FileNew，
	  它的参数为FileNothing，即没有文件。
	*/
	cmdInfo.m_nShellCommand = CCommandLineInfo::FileNothing;


	// 调度在命令行中指定的命令。  如果
	// 用 /RegServer、/Register、/Unregserver 或 /Unregister 启动应用程序，则返回 FALSE。
	if (!ProcessShellCommand(cmdInfo))
		return FALSE;
	// 主窗口已初始化，因此显示它并对其进行更新
	pMainFrame->ShowWindow(m_nCmdShow);
	pMainFrame->UpdateWindow();

	return TRUE;
}

int CImgProcApp::ExitInstance()
{
	//TODO: 处理可能已添加的附加资源
	AfxOleTerm(FALSE);

	return CWinApp::ExitInstance();
}

// CImgProcApp 消息处理程序
// 用于应用程序“关于”菜单项的 CAboutDlg 对话框

//class CAboutDlg : public CDialogEx
//{
//public:
//	CAboutDlg() noexcept;
//
//// 对话框数据
//#ifdef AFX_DESIGN_TIME
//	enum { IDD = IDD_ABOUTBOX };
//#endif
//
//protected:
//	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV 支持
//
//// 实现
//protected:
//	DECLARE_MESSAGE_MAP()
//public:
//
//	CString TEXT1;
////  CString GRAM1;
////	CString m_blueBZC;
////	CString m_greeenBZC;
////	CString m_redBZC;
////	CString m_bluePJHD;
////	CString m_greenPJHD;
////	CString m_redPJHD;
////	CString m_blueXS;
////	CString m_greenXS;
////	CString m_redXS;
////	CString m_blueZZHD;
////	CString m_greenZZHD;
////	CString m_redZZHD;
//
//};
//
////CAboutDlg::CAboutDlg() : m_blueBZC(TEXT(""))noexcept : CDialogEx(IDD_ABOUTBOX)
////, TEXT1(_T(""))
////{
////}
//
//CAboutDlg::CAboutDlg() noexcept : CDialogEx(IDD_ABOUTBOX)
//, TEXT1(_T(""))
//{
//}
//
//void CAboutDlg::DoDataExchange(CDataExchange* pDX)
//{
//	CDialogEx::DoDataExchange(pDX);
//	DDX_Text(pDX, IDC_STATIC_TEXT1, TEXT1);
//	//DDX_Control(pDX, IDC_STATIC_GRAM1, GRAM1);
//
//	//  DDX_Control(pDX, IDC_STATIC_BZC_BLUE, m_blueBZC);
//	//  DDX_Control(pDX, IDC_STATIC_BZC_RED, m_redBZC);
//	//  DDX_Control(pDX, IDC_STATIC_BZC_GREEN, m_greeenBZC);
//
//	//  DDX_Control(pDX, IDC_STATIC_PJHD_RED, m_redPJHD);
//	//  DDX_Control(pDX, IDC_STATIC_PJHD_GREEN, m_greenPJHD);
//	//  DDX_Control(pDX, IDC_STATIC_PJHD_BLUE, m_bluePJHD);
//
//	//  DDX_Control(pDX, IDC_STATIC_ZZHD_RED, m_redZZHD);
//	//  DDX_Control(pDX, IDC_STATIC_ZZHD_GREEN, m_greenZZHD);
//	//  DDX_Control(pDX, IDC_STATIC_ZZHD_BLUE, m_blueZZHD);
//
//	//  DDX_Control(pDX, IDC_STATIC_XS_RED, m_redXS);
//	//  DDX_Control(pDX, IDC_STATIC_XS_GREEN, m_greenXS);
//	//  DDX_Control(pDX, IDC_STATIC_XS_BLUE, m_blueXS);
//
//
//}
//
//BEGIN_MESSAGE_MAP(CAboutDlg, CDialogEx)
//END_MESSAGE_MAP()
//
//// 用于运行对话框的应用程序命令
//void CImgProcApp::OnAppAbout()
//{
//	CAboutDlg aboutDlg;
//	aboutDlg.DoModal();
//}




