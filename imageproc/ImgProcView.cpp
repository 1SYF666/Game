
// ImgProcView.cpp: CImgProcView 类的实现
//

#include "pch.h"
#include "framework.h"
// SHARED_HANDLERS 可以在实现预览、缩略图和搜索筛选器句柄的
// ATL 项目中进行定义，并允许与该项目共享文档代码。
#ifndef SHARED_HANDLERS
#include "ImgProc.h"
#endif

#include "ImgProcDoc.h"
#include "ImgProcView.h"
#include "MainFrm.h"  // 在状态栏添加，显示鼠标位置时添加的头文件 
#include "HSI.h"

//#define DISTANCE(x1, y1, x2, y2) (sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2)))
#define DISTANCE(x1, y1, x2, y2) sqrt((float)((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2)))
#define TWOVALUE 0x80
#define EDGEPOINT 0x70
#define NO_EDGE_POINT 0x8f
#define MARK_VISITED 0x81
#define VISITED 0x01
#define MARKED 0x80
#define NO_MARK 0x7f
#define NO_VISITED 0xfe
#define CENTERED 0x02
#define NO_CENTER 0xfd 



const int pre_shrink_count = 3;



// GLOBALS

CSize Size;

int lWidth = 0, lHeight = 0;			// 图像的宽 高
int lLineBytes = 0;						// 一行所占字节数
unsigned char* lpSrc = NULL;
unsigned char* lpDst = NULL;
unsigned char* mpImage = NULL;
bool m_bFullEdge = true;
long tot_area, tot_x, tot_y, max_radius;		// 用于递归
const double Pi = 3.14159;

RGB* g_pImgBuffer;						// 全局的图像数据
HSI* g_pHSIBuffer;						// 全局的HSI数据

vector<CENTER_POINT>    points_temp;
vector<CENTER_POINT>	m_vCenterPoints;


#ifdef _DEBUG
#define new DEBUG_NEW
#endif


// CImgProcView

IMPLEMENT_DYNCREATE(CImgProcView, CView)

BEGIN_MESSAGE_MAP(CImgProcView, CView)
	// 标准打印命令
	ON_COMMAND(ID_FILE_PRINT, &CView::OnFilePrint)
	ON_COMMAND(ID_FILE_PRINT_DIRECT, &CView::OnFilePrint)
	ON_COMMAND(ID_FILE_PRINT_PREVIEW, &CView::OnFilePrintPreview)
	ON_WM_MOUSEMOVE()
	ON_WM_PAINT()
	ON_COMMAND(ID_HISTGRAM_RGB, &CImgProcView::OnHistgramRgb)
	ON_COMMAND(ID_HISTGRAM_HSI, &CImgProcView::OnHistgramHsi)
	ON_COMMAND(ID_CELLPROCESS_MARK, &CImgProcView::OnCellprocessMark)
	ON_COMMAND(ID_CELLPROCESS_TWOVALUE, &CImgProcView::OnCellprocessTwovalue)
	ON_COMMAND(ID_CELLPROCESS_FILLHOLES, &CImgProcView::OnCellprocessFillholes)
	ON_COMMAND(ID_CELLPROCESS_SHRINK, &CImgProcView::OnCellprocessShrink)
	ON_COMMAND(ID_CELLPROCESS_FINDCENTER, &CImgProcView::OnCellprocessFindcenter)
	ON_COMMAND(ID_CELLPROCESS_COUNT, &CImgProcView::OnCellprocessCount)
END_MESSAGE_MAP()

// CImgProcView 构造/析构

CImgProcView::CImgProcView() noexcept
{
	// TODO: 在此处添加构造代码
	g_pImgBuffer = NULL;
	g_pHSIBuffer = NULL;

}

CImgProcView::~CImgProcView()
{

	if (g_pHSIBuffer)
		delete[] g_pHSIBuffer;

	if (g_pImgBuffer)
		delete[] g_pImgBuffer;


}

BOOL CImgProcView::PreCreateWindow(CREATESTRUCT& cs)
{
	// TODO: 在此处通过修改
	//  CREATESTRUCT cs 来修改窗口类或样式

	return CView::PreCreateWindow(cs);
}

void CImgProcView::OnInitialUpdate()
{
	CView::OnInitialUpdate();

	// TODO: 在此添加专用代码和/或调用基类

	//CImgProcDoc* pDoc = GetDocument();
	//if (pDoc->m_pDib->m_lpBMIH != NULL)
	//{
	//	CString m_fileName;

	//	CHAR strDirName[80];
	//	GetCurrentDirectory(80, L"(LPSTR)strDirName");  //L"(LPCSTR)strPathname"

	//	CString pathName;
	//	pathName.Format(_T("%s"), strDirName);

	//	m_fileName = pathName + TEXT("\\blood.bmp");

	//	CFile file;
	//	if (file.Open(m_fileName, CFile::modeRead | CFile::shareDenyWrite, NULL));
	//	{
	//		pDoc->m_pDib->Read(&file); file.Close();
	//		pDoc->SetTitle(TEXT("blood"));
	//		pDoc->SetPathName(m_fileName); //if not cannot get pDoc->GetPathName
	//		//pDoc->GetPathName();
	//	}
	//}
}



// CImgProcView 绘图

void CImgProcView::OnDraw(CDC* pDC)
{
	CImgProcDoc* pDoc = GetDocument();
	ASSERT_VALID(pDoc);
	if (!pDoc)
		return;

	// TODO: 在此处为本机数据添加绘制代码



	//int lWidth, lHeight;

	if (pDoc->m_pDib->m_lpBMIH != NULL)
	{
		lWidth = pDoc->m_pDib->m_lpBMIH->biWidth;
		lHeight = pDoc->m_pDib->m_lpBMIH->biHeight;
		Size.cx = lWidth;
		Size.cy = lHeight;
		mpImage = (unsigned char*)pDoc->m_pDib->m_lpImage;
		pDoc->m_pDib->Draw(pDC, CPoint(0, 0), Size);


	}

}


bool CImgProcView::LoadBmp()
{
	CImgProcDoc* pDoc = GetDocument();

	CFile file;
	if (file.Open(_T("Blood.bmp"), CFile::modeRead, NULL))
	{
		pDoc->m_pDib->Read(&file);
		file.Close();

	}

	lHeight = pDoc->m_pDib->m_lpBMIH->biHeight;
	lWidth = pDoc->m_pDib->m_lpBMIH->biWidth;
	//m_nDrawHeight = pDoc->m_pDib->m_lpBMIH->biHeight;
	//m_nDrawWidth = pDoc->m_pDib->m_lpBMIH->biWidth;
	//m_nBitCount = pDoc->m_pDib->m_lpBMIH->biBitCount;   //每个像素所占位数  
	////计算图像每行像素所占的字节数（必须是32的倍数）  
	//m_nLineByte = (m_nWidth * m_nBitCount + 31) / 32 * 4; //修改处

	//m_nImage = m_nLineByte * m_nHeight;
	////位图实际使用的颜色表中的颜色数 biClrUsed  
	//m_nPalette = 0;                       //初始化  
	if (pDoc->m_pDib->m_lpBMIH->biClrUsed)
		pDoc->m_pDib->m_lpBMIH->biClrUsed;
	//申请位图空间 大小为位图大小 m_nImage  
	//malloc只能申请4字节的空间 （未知） 
	/*m_pImage = (BYTE*)malloc(m_nImage);*/
	mpImage = pDoc->m_pDib->m_lpImage;
	return true;
}


// CImgProcView 打印

BOOL CImgProcView::OnPreparePrinting(CPrintInfo* pInfo)
{
	// 默认准备
	return DoPreparePrinting(pInfo);
}

void CImgProcView::OnBeginPrinting(CDC* /*pDC*/, CPrintInfo* /*pInfo*/)
{
	// TODO: 添加额外的打印前进行的初始化过程
}

void CImgProcView::OnEndPrinting(CDC* /*pDC*/, CPrintInfo* /*pInfo*/)
{
	// TODO: 添加打印后进行的清理过程
}


// CImgProcView 诊断

#ifdef _DEBUG
void CImgProcView::AssertValid() const
{
	CView::AssertValid();
}

void CImgProcView::Dump(CDumpContext& dc) const
{
	CView::Dump(dc);
}

CImgProcDoc* CImgProcView::GetDocument() const // 非调试版本是内联的
{
	ASSERT(m_pDocument->IsKindOf(RUNTIME_CLASS(CImgProcDoc)));
	return (CImgProcDoc*)m_pDocument;
}
#endif //_DEBUG


// CImgProcView 消息处理程序

void CImgProcView::OnMouseMove(UINT nFlags, CPoint point)
{
	// TODO: 在此添加消息处理程序代码和/或调用默认值

	//CString str;
	//str.Format(TEXT("[%d,%d]  "), point.x, point.y);
	//((CMainFrame*)AfxGetMainWnd())->m_wndStatusBar.SetPaneText(0, str);
	//鼠标是从左上角(0,0)开始的，
	CImgProcDoc* pDoc = GetDocument();
	CString str;

	if (pDoc->m_pDib->m_lpBMIH)
	{

		//使得鼠标位置在图像范围内，超过图像范围则不显示
		if ((point.x > 0) && (point.x < lWidth) && (point.y > 0) && (point.y < lHeight))
		{
			//8位图像
			if (pDoc->m_pDib->m_lpBMIH->biBitCount == 8)
			{
				lLineBytes = (lWidth + 3) / 4 * 4;//8bit
				lpSrc = (unsigned char*)pDoc->m_pDib->m_lpImage
					+ lLineBytes * (lHeight - 1 - point.y) + point.x;
				str.Format(L"(x=%d y=%d)=%d", point.x, point.y, *lpSrc);
			}
			//24位图像
			else if (pDoc->m_pDib->m_lpBMIH->biBitCount == 24)
			{
				lLineBytes = (lWidth * 3 + 3) / 4 * 4;//32bit
				lpSrc = (unsigned char*)pDoc->m_pDib->m_lpImage
					+ lLineBytes * (lHeight - 1 - point.y) + point.x * 3;
				RGB rgb; HSI hsi;
				rgb.b = *lpSrc; rgb.g = *(lpSrc + 1); rgb.r = *(lpSrc + 2);
				RgbtoHsi(&rgb, &hsi);
				int gray = (int)(0.114 * rgb.r + 0.587 * rgb.g + 0.299 * rgb.b);
				str.Format(TEXT("Pos(%d %d)  RGB(%d %d %d) Gray(%d) HSI(%4.1f %3.2f %3.2f---%d %d %d)"),
					point.x, point.y, rgb.r, rgb.g, rgb.b, gray, hsi.Hue, hsi.Saturation, hsi.Intensity,
					(int)(hsi.Hue / 360.0 * 255.0), (int)(hsi.Saturation * 255.0),
					(int)(hsi.Intensity * 255.0));
			}
		}
	}
	((CMainFrame*)AfxGetMainWnd())->m_wndStatusBar.SetPaneText(0, str);
	CView::OnMouseMove(nFlags, point);
}

void CImgProcView::OnHistgramRgb()
{

	// TODO: 在此添加命令处理程序代码
	DispalyDialog dlg;
	CImgProcDoc* pDoc = GetDocument();
	if (pDoc->m_pDib->m_lpBMIH)
	{
		unsigned int red[256], green[256], blue[256]; //储存RGB的直方图
		unsigned int sum_red = 0, sum_green = 0, sum_blue = 0;
		unsigned int avg_red = 0, mid_red = 0;  //avg=average,mid=median;
		unsigned int avg_green = 0, mid_green = 0;  //avg=average,mid=median;
		unsigned int avg_blue = 0, mid_blue = 0;  //avg=average,mid=median;
		int w = lWidth;
		int h = lHeight;

		g_pImgBuffer = (RGB*)malloc(sizeof(RGB) * w * h);
		memcpy(g_pImgBuffer, pDoc->m_pDib->m_lpImage, sizeof(RGB) * w * h);

		RGB* cur = g_pImgBuffer;

		for (int i = 0; i < 256; i++)
		{
			red[i] = 0;
			green[i] = 0;
			blue[i] = 0;
		}


		for (int j = 0; j < h; j++)//计算直方图，原理就是计数
		{
			for (int i = 0; i < w; i++)//
			{

				blue[(int)(cur + j * w + i)->b]++;
				green[(int)(cur + j * w + i)->g]++;
				red[(int)(cur + j * w + i)->r]++;
			}
		}

		//像素:int型转换为CString型 
		dlg.m_redXS.Format(TEXT("%d"), w * h);
		dlg.m_greenXS.Format(TEXT("%d"), w * h);
		dlg.m_blueXS.Format(TEXT("%d"), w * h);


		for (int i = 0; i < 256; i++)//计算平均灰度
		{
			sum_red += red[i] * i;
			sum_green += green[i] * i;
			sum_blue += blue[i] * i;
		}
		avg_red = sum_red / (w * h);
		avg_green = sum_green / (w * h);
		avg_blue = sum_blue / (w * h);

		dlg.m_redPJHD.Format(TEXT("%d"), avg_red);
		dlg.m_greenPJHD.Format(TEXT("%d"), avg_green);
		dlg.m_bluePJHD.Format(TEXT("%d"), avg_blue);

		/****************************************************************/
		/* 中值灰度:算法重点
		/* 中值灰度:所有像素中的中位数,应该所有像素排序找到中间的灰度值
		/* 算法:num[256]记录各灰度出现次数,sum+=num[i],找到sum=总像素/2
		/****************************************************************/
		int sumRedZZHD = 0, sumGreenZZHD = 0, sumBlueZZHD = 0;
		int redZZHD, greenZZHD, blueZZHD;
		for (int i = 0; i < 256; i++)
		{
			sumRedZZHD = sumRedZZHD + red[i];
			if (sumRedZZHD >= w * h / 6)          //m_nImage被分成3份RGB并且sum=总像素/2
			{
				redZZHD = i;
				break;
			}
		}
		for (int i = 0; i < 256; i++)
		{
			sumGreenZZHD = sumGreenZZHD + green[i];
			if (sumGreenZZHD >= w * h / 6)          //m_nImage被分成3份RGB并且sum=总像素/2
			{
				greenZZHD = i;
				break;
			}
		}
		for (int i = 0; i < 256; i++)
		{
			sumBlueZZHD = sumBlueZZHD + blue[i];
			if (sumBlueZZHD >= w * h / 6)          //m_nImage被分成3份RGB并且sum=总像素/2
			{
				blueZZHD = i;
				break;
			}
		}

		dlg.m_redZZHD.Format(TEXT("%d"), redZZHD);
		dlg.m_greenZZHD.Format(TEXT("%d"), greenZZHD);
		dlg.m_blueZZHD.Format(TEXT("%d"), blueZZHD);


		// red[i]是CImage_ProcessingView::OnHistogram()中的变量，  
		// dlg.Red[i]是对话框中的变量，
		// 对话框根据  dlg.Red[i]画直方图

		for (int i = 0; i < 256; i++)
		{

			dlg.Red[i] = red[i];
			dlg.Green[i] = green[i];
			dlg.Blue[i] = blue[i];
			dlg.w = w;
			dlg.h = h;

		}
	}

	//打开对话框
	if (dlg.DoModal() == IDOK)
	{

	}


	//*************释放内存**************
	g_pImgBuffer = NULL;
	free(g_pImgBuffer);


}

void CImgProcView::OnHistgramHsi()
{
	// TODO: 在此添加命令处理程序代码
	HSIDialog dlg;


	//打开对话框
	if (dlg.DoModal() == IDOK)
	{




	}

}

void CImgProcView::OnCellprocessMark()
{
	// TODO: 在此添加命令处理程序代码
	CImgProcDoc* pDoc = GetDocument();
	/*mark - red; may be mark - blue; not Mark or not maybe mark*/

	unsigned char* lpNewDIBBits;			//暂时分配内存，已保存新图像
	lpNewDIBBits = new unsigned char[lHeight * lLineBytes];
	lpSrc = (unsigned char*)mpImage;
	memcpy(lpNewDIBBits, lpSrc, lLineBytes * lHeight);



	double meanH = 210.0 * 360 / 255;
	double meanS = 55.0 / 255;
	double MarkDoor = 0.09;
	double MayBeMarkDoor = 0.15;

	//遍历整个图像
	for (int i = 1; i < lHeight-1; i++)
	{
		for (int j = 1; j < lWidth-1; j++)
		{
			lpSrc = mpImage+ lLineBytes * (lHeight - 1 - i) + j * 3;
			RGB rgb; HSI hsi;
			rgb.b = *lpSrc; rgb.g = *(lpSrc + 1); rgb.r = *(lpSrc + 2);
			RgbtoHsi(&rgb, &hsi);

			double x1 = hsi.Hue;//  0-360
			double x2 = meanH;  // 近似
			
			if (x1 < 90) x1 += 360;

			double y1 = hsi.Saturation;
			double y2 = meanS;
			x1 /= 180;//归一化
			x2 /= 180;  //0-1;

			double dis = DISTANCE(x1, y1, x2, y2);

			if (dis < MarkDoor)
			{	//Mark
				*lpSrc = 0; *(lpSrc + 1) = 0; *(lpSrc + 2) = 255;//Red
			}
			else if (dis < MayBeMarkDoor)
			{	//may be Mark
				*lpSrc = 255; *(lpSrc + 1) = 0; *(lpSrc + 2) = 0;//Blue
			}
			else
			{	//not Mark/maybe Mark
				if (*lpSrc == 0) *lpSrc = 1;//Mark
				else if (*lpSrc == 255) *lpSrc = 254;//maybe mark
				else if (*(lpSrc + 2) == 128) *lpSrc = 127;//maybe2mark
				if (*(lpSrc + 1) == 255) *(lpSrc + 1) = 254; //edge			    }
			}

		}

	}

	Invalidate(true);
	MessageBox(TEXT("Mark(red) || mayMark(blue)"));


	bool MarkCha = true; //标志位

	while (MarkCha)
	{
		//由于蓝色部分可能是细胞的 ，所以对蓝色部分进行判断，判断是细胞的，标记为暗红色
		MarkCha = false;
		for (int i = 1; i < lHeight-1; i++)
		{
			for (int j = 1; j < lWidth-1; j++)
			{
				lpSrc = mpImage+ lLineBytes * (lHeight - 1 - i) + j * 3;

				if (*lpSrc == 255) //B=255
				{
					//maybe Mark
					bool bProc = false;		//暂时不要修改，该像素是否为蓝色？

					//用四邻域判断：
					if (j > 0)
					{
						if (*(lpSrc - 3) == 0)//左边像素为 红色（255，0，0） or 暗红色（128，0，0）
							bProc = true;
					}
					if (j < lWidth - 1)
					{
						if (*(lpSrc + 3) == 0)//右边像素为 红色（255，0，0） or 暗红色（128，0，0）
							bProc = true;
					}
					if (i > 0)
					{
						if (*(lpSrc + lLineBytes) == 0)  //上边像素为 红色（255，0，0） or 暗红色（128，0，0）
							bProc = true;
					}
					if (i < lLineBytes - 1)              // bug！！！！！！
					{
						if (*(lpSrc - lLineBytes) == 0)  //下边像素为 红色（255，0，0） or 暗红色（128，0，0）
							bProc = true;
					}

					//maybe Mark have Mark Point to Mark
					if (bProc)
					{
						*lpSrc = 0;
						MarkCha = true;
						*(lpSrc + 2) = 128; //标记为暗红色，后续认为是该像素属于细胞
					}
				}
			}

		}

	}

	Invalidate(true);
	MessageBox(TEXT("maybe Mark to mark (Bright Red(128,0,0))"));


	// 获取细胞边缘，目的是区互相黏连的红色部分含有多少个细胞
	// 提取边缘的对象：最初标记的红色部分 以及 由蓝色转化成的暗红色部分
	// 
	const int edgeDoor = 45;

	for (int i = 1; i < lHeight - 1; i++)
	{
		for (int j = 1; j < lWidth - 1; j++)
		{
			lpDst = mpImage+ lLineBytes * (lHeight - 1 - i) + j * 3;

			if (*(lpDst) == 0 || *(lpDst) == 255)
			{
				//当前像素为 红色 or 暗红 或者 第一次标记的蓝色（可能也为细胞，但是没有变成暗红色）

				//Mark Maybe Mark
				double pixel[9];

				//lpSrc指向的地址是原图像。
				lpSrc = lpNewDIBBits + lLineBytes * (lHeight - 1 - i) + j * 3;

				//提取该像素周围领域（3*3）
				for (int m = -1; m < 2; m++)
				{
					for (int n = -1; n < 2; n++)
					{
						unsigned char* lpSrc1 = lpSrc - lLineBytes * m + 3 * n;
						//把读入原图像像素中含有三原色（RGB）求一个平均值，此处容易受 blue=255 的影响
						pixel[(m + 1) * 3 + n + 1] = ((int)(*lpSrc1 + *(lpSrc1 + 1) + *(lpSrc1 + 2))) / 3;

					}
				}

				double tmp1 = pixel[0] + 2 * pixel[1] + pixel[2] - pixel[6] - 2 * pixel[7] - pixel[8];
				double tmp2 = pixel[0] + 2 * pixel[3] + pixel[6] - pixel[2] - 2 * pixel[5] - pixel[8];

				double edge = sqrt(tmp1 * tmp1 + tmp2 * tmp2);

				if (edge > edgeDoor)
				{
					*(lpDst + 1) = 255; //edge  
				}
			}
		}
	}

	Invalidate(true);

	MessageBox(TEXT("边缘检测后未滤波"));


	// 边缘滤波：可能出现两种情况：
	// 一个细胞内被添加了边缘（舍去）；多个细胞粘连后被标记出来边缘（保留）
	// 对上面两种边缘进行区分思想：10*10矩形，，对标记的边缘像素 领域 进行判断，如果周围是暗红或红色，
	// 则该边缘属于第一种情况（舍去）；否则，属于第二种情况（保留）

	const int M = 5;
	bool bdelete = true;

	for (int i = 1+M; i < lHeight-1 - M; i++)
	{
		for (int j = 1+M; j < lWidth-1 - M; j++)
		{
			lpDst = mpImage + lLineBytes * (lHeight - 1 - i) + j * 3;
			if (*(lpDst + 1) == 255)//先前被标记为边缘
			{
				bdelete = true;

				for (int m = -M; m <= M; m++)
				{
					for (int n = -M; n <= M; n++)
					{
						//对5*5矩形中的四个拐角进行判断处理
						if (m == -M || m == M || n == -M || n == M)
						{
							//如果周围遇到之前没有标记的背景或者已经标记的Blue
							if (*(lpDst + lLineBytes * m + n * 3) || (*(lpDst + lLineBytes * m + n * 3 + 1)) == 255)  //bug!!!!!
							{
								bdelete = false; //该标记的边缘像素属于第二种情况（保留）
								m = M + 1;
								n = M + 1;
							}
						}
					}
				}

				if (bdelete)
				{
					*(lpDst + 1) = 0;  //删除边缘
				}
			}
		}
	}

	Invalidate(true);

	MessageBox(TEXT("get the edge of cell"));

	//*************释放内存*******************
	lpNewDIBBits = NULL;
	free(lpNewDIBBits);

}

// mark操作步骤之后，现在图像包含部分：
// RGB（x x x） (*lpSrc+2 *lpSrc+1 *lpSrc)
// 细胞：红色（255，0，0） 暗红色（128 0 0）
// 边缘：三种颜色组成 黄色（255，255，0）、（128 255 0） 以及（0 255 255） 
// 背景但被误标记为蓝色：蓝色（0，0，255）
// 背景：RGB为原图像值
//

void CImgProcView::OnCellprocessTwovalue()
{
	// TODO: 在此添加命令处理程序代码

	CImgProcDoc* pDoc = GetDocument();

	//申请一个八位图像内存空间
	int lNewLineBytes = 0;
	lNewLineBytes = (lWidth + 3) / 4 * 4;  //8bit
	unsigned char* lpNewDIBBits;
	lpNewDIBBits = new unsigned char[lHeight * lNewLineBytes];

	for (int i = 1; i < lHeight-1; i++)
	{
		for (int j = 1; j < lWidth-1; j++)
		{
			lpSrc = mpImage+ lLineBytes * (lHeight - 1 - i) + j * 3;
			lpDst = lpNewDIBBits + lNewLineBytes * (lHeight - 1 - i) + j;

			unsigned char v;
			v = 0;				//背景 黑
			if (*(lpSrc) == 0)  //已经标记成红色或者暗红色的部分
			{
				v = TWOVALUE;
				if (*(lpSrc + 1))
				{
					v |= EDGEPOINT;      //边缘标成0xf0 亮
				}
				else
				{
					//图像最外边一周
					if (j == 0 || j == lWidth - 1 || i == 0 || i == lHeight - 1)
					{
						v |= EDGEPOINT;  //边缘标成0xf0 亮
					}
				}
			}
			*lpDst = (unsigned char)v;
		}
	}

	lLineBytes = lNewLineBytes;

	delete pDoc->m_pDib;    //删除之前的彩色图像，目的是为了显示二值图像。
	pDoc->m_pDib = new CDib(CSize(lNewLineBytes, lHeight), 8);   // 生成一个图像，大小为CSize,8位

	lpSrc = (unsigned char*)pDoc->m_pDib->m_lpvColorTable;       // 调色板

	// 查找表 4*256=1024，没有此查找表显示不出图像
	for (int i = 0; i < 256; i++)
	{
		*lpSrc = (unsigned char)i; lpSrc++;
		*lpSrc = (unsigned char)i; lpSrc++;
		*lpSrc = (unsigned char)i; lpSrc++;
		*lpSrc = 0; lpSrc++;
	}

	memcpy(pDoc->m_pDib->m_lpImage, lpNewDIBBits, lLineBytes * lHeight);

	Invalidate(true);


	//*************释放内存*******************
	lpNewDIBBits = NULL;
	delete[]lpNewDIBBits;

}

// 二值化后的图像组成：
// 背景以及细胞内的洞：值=0
// 细胞：值=128 ox80 1000 0000
// 细胞边缘：值=  240 oxf0 1111 0000
//          或者 0|0x70   0111 0000

// MARK_VISITED		1000 0001
// EDGEPOINT		0111 0000
// MARKED 0x80      1000 0000
// 

void CImgProcView::OnCellprocessFillholes()
{
	// TODO: 在此添加命令处理程序代码

	//0x7X---edge
	//0x8X---Mark--not edge
	//0xfX--Mark –edge
	//0xX1---visited


	CImgProcDoc* pDoc = GetDocument();

	for (int i = 1; i < lHeight - 1; i++)
	{
		for (int j = 1; j < lWidth - 1; j++)
		{
			lpSrc = (unsigned char*)pDoc->m_pDib->m_lpImage
				+ lLineBytes * (lHeight - 1 - i) + j;
			//MARK_VISITED 1000 0001 
			//当该像素为0时，条件为真，进行填洞
			if (!(*lpSrc & MARK_VISITED))
			{
				ProcessFillHoles(j, i);
			}

		}
	}
	
	MessageBox(TEXT("FillHole"));


	for (int i = 1; i < lHeight-1; i++)
	{
		for (int j = 1; j < lWidth-1; j++)
		{
			lpSrc = (unsigned char*)pDoc->m_pDib->m_lpImage
				+ lLineBytes * (lHeight - 1 - i) + j;
			// 图像处理完之后，本来就是洞的像素是0，变成了*lpSrc | VISITED=0x01;  

			if (!(*lpSrc & MARKED))  // MARKED 0x80 --- 1000 0000
			{
				// *lpSrc=0或者*lpSrc=1时满足执行，
				// 为什么还有*lpSrc=1，可能标志了 没有填洞赋值为10000001=129
				// 即没有进行（*lpSrc |= MARKED=0x01||0x80=0x81=129; ）
				*lpSrc = 0;  //将该像素置为0；
			}

			else
			{
				// 进入这里的像素值为：*lpSrc=129、128或者240
				// 10000001  10000000  11110000
				if (*lpSrc & EDGEPOINT)			//细胞边缘时
				{
					// 进入这里时，像素值*lpSrc=11110000=240，
					// 即把细胞边缘也变黑，为了后面分离各个细胞做了伏笔
					*lpSrc = 0;
				}
			}
		}
	}


	Invalidate(true);
}

// 图像地址：左下至右上
// 鼠标远点：左上至右下

void CImgProcView::ProcessFillHoles(int wd, int ht)
{
	CImgProcDoc* pDoc = GetDocument();

	stack <CPoint> s;
	vector<CPoint> v;

	const int MAX_HOLE = 100;
	int xt, yt;
	xt = wd;
	yt = ht;
	s.push(CPoint(xt, yt));
	v.push_back(CPoint(xt, yt));

	unsigned char* lpSrc;
	lpSrc = (unsigned char*)pDoc->m_pDib->m_lpImage +
		lLineBytes * (lHeight - 1 - yt) + xt;  // 现在一行占据8个字节

	//VISITED=0x01,入栈时该像素为0，然后把该像素改为：0x00 | 0x01=1,
	//标志着 该像素已经入栈，后期不再进行入栈操作
	*lpSrc |= VISITED;

	bool bBorder = false;

	while (s.size())
	{
		// 增加新的像素为0的点 到栈中
		// 选择此像素上下左右四个点，去判断是否是洞，像素为0即为洞
		// 该像素的上面
		lpSrc = (unsigned char*)pDoc->m_pDib->m_lpImage
			+ lLineBytes * (lHeight - 1 - yt) + xt;
		// 当前像素上
		// 没有入过栈的：*(lpSrc + lLineBytes)=0时，与 MARK_VISITED 1000 0001，值为0
		// 已经入过栈的: *(lpSrc + lLineBytes)=1时，与 MARK_VISITED 1000 0001，值为1

		if (yt > 0)
		{
			//当前像素不在最上面一行
			if (!(*(lpSrc + lLineBytes) & MARK_VISITED))
			{
				s.push(CPoint(xt, yt - 1));
				v.push_back(CPoint(xt, yt - 1));
				*(lpSrc + lLineBytes) |= VISITED;
			}
		}
		else
		{
			//当前像素在最上面一行，即所属边界、
			bBorder = true;
		}

		// 当前像素下

		if (yt < lHeight - 1)
		{
			//当前像素不在最下面一行
			if (!(*(lpSrc - lLineBytes) & MARK_VISITED))
			{
				s.push(CPoint(xt, yt + 1));
				v.push_back(CPoint(xt, yt + 1));
				*(lpSrc - lLineBytes) |= VISITED;
			}

		}
		else
		{
			//当前像素在最上面一行，即所属边界、
			bBorder = true;
		}

		// 当前像素左
		if (xt > 0)
		{
			//当前像素不在最左边一行
			if (!(*(lpSrc - 1) & MARK_VISITED))
			{
				s.push(CPoint(xt - 1, yt));
				v.push_back(CPoint(xt - 1, yt));
				*(lpSrc - 1) |= VISITED;
			}
		}
		else
		{
			//当前像素在最左边一行，即所属边界、
			bBorder = true;
		}

		// 当前像素右
		if (xt < lWidth - 1)
		{
			//当前像素不在最右边一行
			if (!(*(lpSrc + 1) & MARK_VISITED))
			{
				s.push(CPoint(xt + 1, yt));
				v.push_back(CPoint(xt + 1, yt));
				*(lpSrc + 1) |= VISITED;
			}
		}
		else
		{
			//当前像素在最右边一行，即所属边界、
			bBorder = true;
		}

		// 获得 上面最后入栈的像素坐标x,y
		xt = s.top().x;
		yt = s.top().y;
		s.pop(); //删除上面最后入栈的像素位置

		// 利用 上面最后入栈的像素坐标x,y
		// 再次进入循环中，遍历此时像素x,y的上下左右，进行入栈操作
		// 显然，如果最后上下左右都不符合入栈要求，则栈继续取最上面x,y，进入循环，栈长度也依次变小
		// 直到最后为0 跳出循环
	}


	// 填洞

	if (v.size() < MAX_HOLE && !bBorder)
	{
		CString msg;


		msg.Format(TEXT("\n%d --(%d %d)"), v.size(), wd, ht);

		//显示 只看 组成大于50个像素点为0的洞的位置
		if (v.size() > 50)
		{
			Invalidate(true);
			MessageBox(msg);
		}
		else
		{
			TRACE(msg);
		}
		//实际对入栈后的像素值为 1=0x00||VISITED=0x00||0x01,
		//进行填洞，将该像素改变 *lpSrc |= MARKED=0x01||0x80=0x81=129;

		for (unsigned int k = 0; k < v.size(); k++)
		{
			xt = v[k].x;
			yt = v[k].y;
			lpSrc = pDoc->m_pDib->m_lpImage +
				lLineBytes * (lHeight - 1 - yt) + xt;

			*lpSrc |= MARKED;
		}
	}
}

// 填洞之后：图像中的像素组成如下：
// 背景(和部分细胞边缘也变成黑了)：像素值 0
// 细胞像素128                1000 0000
// 像素为0 然后填洞变成了：129 1000 0001
// EDGEPOINT=0x70=           0111 0000
// NO_MARK=0x7f				 0111 1111
// NO_EDGE_POINT 0x8f        1000 1111
void CImgProcView::OnCellprocessShrink()
{
	// TODO: 在此添加命令处理程序代码

	//CImgProcDoc* pDoc = GetDocument();

	GenEdge();  //先 生成边界

	for (int k = 0; k < pre_shrink_count; k++)
	{
		for (int i = 1; i < lHeight-1; i++)
		{
			for (int j = 1; j < lWidth-1; j++)
			{

				lpSrc = (unsigned char*)mpImage +
					lLineBytes * (lHeight - 1 - i) + j;

				// 如果该像素是边界
				if (*lpSrc & EDGEPOINT)
				{
					// 把该像素变成背景
					// NO_MARK=0x7f=0111 1111
					(*lpSrc) &= NO_MARK;
					//(*lpSrc) = 0;
				}

			}
		}

		if (k % 2 == 0)
		{
			GenEdge();
		}
		else
		{
			GenEdge4();
		}

		//GenEdge();

	}

	Invalidate(true);
}

void CImgProcView::GenEdge()
{
	//CImgProcDoc* pDoc = GetDocument();

	for (int i = 1; i < lHeight-1; i++)
	{
		for (int j = 1; j < lWidth-1; j++)
		{
			lpSrc = (unsigned char*)mpImage +
				lLineBytes * (lHeight - 1 - i) + j;
			// NO_EDGE_POINT 0x8f
			*lpSrc &= NO_EDGE_POINT;  //该点位于边界(0xf0)，先将边界清除 ,使得细胞边界变成细胞。

			if (*lpSrc & MARKED)
			{
				if (j == 0 || i == 0 || j == lWidth - 1 || i == lHeight - 1)
				{
					*lpSrc |= EDGEPOINT;
				}
				// 八方向边界
				// 该像素八个领域中有一个像素不为细胞marked，就把该像素赋为边缘
				else if (!((*(lpSrc - lLineBytes - 1) & MARKED)  // 左下
					&& (*(lpSrc - lLineBytes) & MARKED)		     // 下
					&& (*(lpSrc - lLineBytes + 1) & MARKED)		 // 右下
					&& (*(lpSrc - 1) & MARKED)					 // 左
					&& (*(lpSrc + 1) & MARKED)				     // 右
					&& (*(lpSrc + lLineBytes - 1) & MARKED)		 // 左上
					&& (*(lpSrc + lLineBytes) & MARKED)			 // 上
					&& (*(lpSrc + lLineBytes + 1) & MARKED)))	 // 右上

				{
					*lpSrc |= EDGEPOINT;
				}
			}
		}

	}

	return;
}

void CImgProcView::GenEdge4()
{
	//CImgProcDoc* pDoc = GetDocument();

	for (int i = 1; i < lHeight-1; i++)
	{
		for (int j = 1; j < lWidth-1; j++)
		{
			lpSrc = (unsigned char*)mpImage +
				lLineBytes * (lHeight - 1 - i) + j;

			*lpSrc &= NO_EDGE_POINT;

			if (*lpSrc & MARKED)
			{
				if (j == 0 || i == 0 || j == lWidth - 1 || i == lHeight - 1)
				{
					*lpSrc |= EDGEPOINT;
				}
				// 四方向边界
				else if (!((*(lpSrc - lLineBytes) & MARKED)	     // 下
					&& (*(lpSrc - 1) & MARKED)					 // 左
					&& (*(lpSrc + 1) & MARKED)				     // 右
					&& (*(lpSrc + lLineBytes) & MARKED)))		 // 上 	 
				{
					*lpSrc |= EDGEPOINT;
				}

			}
		}

	}

	return;
}

// shrink 后的图像之后，像素组成是：
// 背	景：像素为0
// 细	胞：像素为128
// 细胞边缘：像素为240
//

void CImgProcView::OnCellprocessFindcenter()
{
	// TODO: 在此添加命令处理程序代码
	bool bChanged = true;

	CENTER_POINT pt;

	points_temp.clear();

	//for (int k = 0; bChanged; k++)
	for (int k = 0; k<100; k++)
	{
		bChanged = false;

		//清除访问visited标志
		for (int j = 1; j < lHeight-1; j++)
		{
			lpSrc = (unsigned char*)mpImage + lLineBytes * (lHeight - 1 - j) + 1 - 1;
			
			for (int i = 1; i < lWidth-1; i++)
			{
				lpSrc++;
				*lpSrc &= NO_VISITED; //NO_VISITED 0xfe 1111 1110
			}
		}

		for (int j = 1; j < lHeight - 1; j++)
		{
			lpSrc = (unsigned char*)mpImage + lLineBytes * (lHeight - 1 - j) + 1 - 1;
			for (int i = 1; i < lWidth - 1; i++)  // 从1开始是不想处理图像边界部分
			{
				lpSrc++;

				m_bFullEdge = true;

				//没有访问过的边界
				if (*lpSrc & EDGEPOINT && !(*lpSrc & VISITED))
				{
					if (!(*(lpSrc - 1) & MARKED) &&   // MARKED = 0x80
						!(*(lpSrc + 1) & MARKED) &&
						!(*(lpSrc + lLineBytes) & MARKED) &&
						!(*(lpSrc - lLineBytes) & MARKED)
						)
					{
						// 显然该像素上下左右四个点都是背景的话，则有两种可能：噪声点 或者 可能是中心点
						// 1 .噪声点
						if (k <= 2) 
							continue;

						// 2.孤立的点，则认为是中心点，进行保存。即保存像素点坐标和半径
						*lpSrc |= CENTERED;  // CENTERED=0x2,给该中心的像素进行 标记

						//保存一下中心点信息
						pt.x = i;	pt.y = j;
						pt.radius = k + pre_shrink_count + 4;//半径计算=收缩次数+补偿 
						points_temp.push_back(pt);



						continue;
					}
					else
					{
						// 显然该像素上下左右四个点至少有一个不是背景的话
						// (即边缘或者细胞)，则执行下面MarkIt函数判断是否需要保存：



						MarkIt(i, j); 
					}
						// 没有访问过标志了并且是边缘邻域
						// 需要保存
					if (m_bFullEdge)
					{
						SaveIt(i, j, k + pre_shrink_count + 4);  //保存
					}
				}
			}
		}

		for (int j = 1; j < lHeight-1; j++)
		{

			lpSrc = (unsigned char*)mpImage + lLineBytes * (lHeight - 1 - j) + 1 - 1;

			for (int i = 1; i < lWidth-1; i++)
			{
				lpSrc++;

				// 去掉边界
				if (*lpSrc & EDGEPOINT)
				{
					bChanged = true;
					*lpSrc &= NO_MARK;
				}
			}
		}

		// 再生成边界，即收缩操作
		if (k % 2 == 0)
		{
			GenEdge4();
		}
		else
		{
			GenEdge();
		}

		if (!bChanged)
		{
			break;
		}

	}

	CString msg;
	msg.Format(TEXT("获得的中心点数目= %d"), points_temp.size());
	MessageBox(msg);

	// 取平均值，获得中心点、
	// 上面操作可能使得一个细胞出现多个中心点
	// 下面操作尽可能减少中心点的个数
	// 将减少后的中心点 统计到 points容器中

	vector<CENTER_POINT> points;

	for (int j = 1; j < lHeight-1; j++)
	{
		lpSrc = (unsigned char*)mpImage + lLineBytes * (lHeight - 1 - j) + 1 - 1;
		for (int i = 1; i < lWidth-1; i++)
		{
			lpSrc++;

			if (*lpSrc & CENTERED)
			{
				
				if (!(*(lpSrc - 1) & CENTERED) && !(*(lpSrc + 1) & CENTERED) &&
					!(*(lpSrc + lLineBytes) & CENTERED) &&
					!(*(lpSrc - lLineBytes) & CENTERED) &&
					!(*(lpSrc + lLineBytes - 1) & CENTERED) &&
					!(*(lpSrc + lLineBytes + 1) & CENTERED) &&
					!(*(lpSrc - lLineBytes - 1) & CENTERED) &&
					!(*(lpSrc - lLineBytes + 1) & CENTERED))
				{
					// 若附件没有中心点，则认为孤立的中心点
					// 存到points容器中

					pt.x = i;
					pt.y = j;
					for (unsigned int n = 0; n < points_temp.size(); n++)
					{
						//遍历之前保存的中心点信息，查找该中心点的半径
						if (points_temp.at(n).x == i && points_temp.at(n).y == j)
						{
							pt.radius = points_temp.at(n).radius;
							break;
						}
					}
					points.push_back(pt);
					continue;
				}
				else
				{
					// 若有中心点，则开始计算取取平均值

					tot_area = 0;				  // 每一次循环进入这里，都可以将这里赋值0
					max_radius = 0;				  // 然后接下来继续进入calcCenterArea函数 
					tot_x = 0;					  // 再赋值给这个参数
					tot_y = 0;
					CalcCenterArea(i, j);         // 计算其邻域（相连）中心点的质点与最大半径并去除其中心点标志
					pt.x = tot_x / tot_area;	  // 横坐标取平均值
					pt.y = tot_y / tot_area;	  // 纵坐标取平均值
					pt.radius = max_radius;       // 取附近中心点的最大半径
					*(lpSrc - (pt.y - j) * lLineBytes + pt.x - i) |= CENTERED;
					points.push_back(pt);

				}
			}
		}
	}
	msg.Format(TEXT("取平均值,获得中心点数目= %d"), points.size());
	MessageBox(msg);

	// draw to display points

	CDC* pdc = GetDC();

	/*
		PEN CreatePen(int nPenStyle, int nWidth, COLORREF crColor);
		nPenStyle  -- Long，指定画笔样式 PS_SOLID转到定义就能找到相同类型的其他线条样式
		nWidth --Long,画笔的宽度
		crColor --Long？画笔的颜色 可通过RGB(r,g,b)函数取得。
	*/

	CPen	Redpen;
	Redpen.CreatePen(PS_DOT, 1, RGB(255, 0, 0));		// 红笔 - 细
	CPen	Redpen1;
	Redpen1.CreatePen(PS_DOT, 3, RGB(255, 0, 0));       // 红笔 - 宽
	CPen Greenpen;
	Greenpen.CreatePen(PS_DOT, 1, RGB(0, 255, 0));      // 绿笔 - 细
	CPen Bluepen;
	Bluepen.CreatePen(PS_DOT, 1, RGB(0, 0, 255));       // 蓝笔 - 细
	CPen Bluepen1;
	Bluepen1.CreatePen(PS_DOT, 3, RGB(0, 0, 255));      // 蓝笔 - 宽

	m_vCenterPoints.clear();
	int x0, y0;
	bool adj;
	// 清除center标志
	for (int j = 1; j <= lHeight-1; j++)
	{
		lpSrc = (unsigned char*)mpImage + lLineBytes * (lHeight - 1 - j) + 1 - 1;
		for (int i = 1; i <= lWidth-1; i++)
		{
			lpSrc++;
			*lpSrc &= NO_CENTER;
		}
	}
	// 平均化相近的中心点

	for (unsigned int i = 0; i < points.size(); i++)
	{
		x0 = points.at(i).x;
		y0 = points.at(i).y;
		pt = points.at(i);

		adj = false;

		//Red 相近- delete
		pdc->SelectObject(Redpen);  //选择细红笔
		
		for (unsigned int j = i + 1; j < points.size() - 1; j++)
		{
			int x = points.at(j).x;
			int y = points.at(j).y;
			
			// 因为细胞半径至少为5
			if (abs(x0 - x) + abs(y0 - y) < 10) // 相近 //圆心距离
			{
				points.at(i).x = (x + x0) / 2;
				points.at(i).y = (y + y0) / 2;
				points.at(i).radius = (points.at(i).radius + points.at(j).radius) / 2;

				pt = points.at(j);

				//display err position--delete 
				/*
					BOOL Arc(HDC hdc,int xLeft,int yTop,int xRight,int yBottom,int XStart,int YStart,int XEndA,int YEnd);
					前四个参数是外接矩形的左上角坐标和右下角坐标
					后四个参数是圆弧开始的坐标和圆弧结束的坐标
				*/
				Arc(pdc->m_hDC,//-3 for display 
					pt.x - pt.radius + 3,
					pt.y - pt.radius + 3,
					pt.x + pt.radius - 3,
					pt.y + pt.radius - 3,
					pt.x + pt.radius - 3,
					pt.y - 3,
					pt.x + pt.radius - 3,
					pt.y - 3
				);

				points.erase(points.begin() + j);//&points.at(j));
				i--;
				adj = true;
				break;
			}
		}
		if (!adj) // 非相近
		{
			if (points.at(i).radius > 4)
			{
				m_vCenterPoints.push_back(points.at(i));
				*(mpImage + lLineBytes * (lHeight - 1 - points.at(i).y) + points.at(i).x) |= CENTERED;
				if (i % 5 == 0 && i)	TRACE("\n");
				TRACE("%3d:(%3d %3d)--%2d\t", i, points.at(i).x, points.at(i).y, points.at(i).radius);
				//display position
				pdc->SelectObject(Greenpen);
				
				Arc(pdc->m_hDC,
					pt.x - pt.radius,
					pt.y - pt.radius,
					pt.x + pt.radius,
					pt.y + pt.radius,
					pt.x + pt.radius, // 从极坐标角度值为0时开始画图
					pt.y,
					pt.x + pt.radius,
					pt.y
				);

			}
		}
	}
	msg.Format(TEXT("平均化相近的中心点后数目= %d"), m_vCenterPoints.size());
	MessageBox(msg);

	int r0, r;
	int tx, ty;
	// 去掉被包含的圆
	//Blue 相近- delete
	bool bdelete = false;
	pdc->SelectObject(Bluepen1);
	for (unsigned int i = 0; i < m_vCenterPoints.size(); i++)
	{
		x0 = m_vCenterPoints.at(i).x;
		y0 = m_vCenterPoints.at(i).y;
		r0 = m_vCenterPoints.at(i).radius;
		for (unsigned int j = i + 1; j < m_vCenterPoints.size() - 1; j++)
		{
			int x = m_vCenterPoints.at(j).x;
			int y = m_vCenterPoints.at(j).y;
			r = m_vCenterPoints.at(j).radius;
			if (DISTANCE(x0, y0, x, y) < abs(r0 - r) + 1) // 包含
			{
				bdelete = true;
				if (r0 > r) // 
					pt = m_vCenterPoints.at(i);
				else
					pt = m_vCenterPoints.at(j);
				Arc(pdc->m_hDC,
					pt.x - pt.radius,
					pt.y - pt.radius,
					pt.x + pt.radius,
					pt.y + pt.radius,
					pt.x + pt.radius,
					pt.y,
					pt.x + pt.radius,
					pt.y
				);
				if (r0 > r) // 去掉r0
				{
					m_vCenterPoints.erase(m_vCenterPoints.begin() + i);//(&m_vCenterPoints.at(i));
					i--;
				}
				else
					m_vCenterPoints.erase(m_vCenterPoints.begin() + j);//(&m_vCenterPoints.at(j));
			}
		}
	}
	if (bdelete) {
		msg.Format(TEXT("去掉被包含的圆(蓝 )后数目= %d"), m_vCenterPoints.size());
		MessageBox(msg);
	}

	vector<CENTER_POINT> tocheck;
	int total;
	bool isok;

	// 去掉潜在的错误(圆 r<9)
	pdc->SelectObject(Redpen1);
	bdelete = false;
	for (unsigned int i = 0; i < m_vCenterPoints.size(); i++)
	{	//baord area process
		CENTER_POINT centerp;
		centerp = m_vCenterPoints.at(i);
		if (centerp.x - centerp.radius < 0)
			centerp.radius -= (centerp.x - centerp.radius);
		if (centerp.y - centerp.radius < 0)
			centerp.radius -= (centerp.y - centerp.radius);
		if (centerp.x + centerp.radius > lWidth - 1)
			centerp.radius += (centerp.x + centerp.radius - lWidth);
		if (centerp.y + centerp.radius > lHeight - 1)
			centerp.radius += (centerp.y + centerp.radius - lHeight);

		if (m_vCenterPoints.at(i).radius < 8) // need adjust <
		{

			Arc(pdc->m_hDC,
				centerp.x - centerp.radius,
				centerp.y - centerp.radius,
				centerp.x + centerp.radius,
				centerp.y + centerp.radius,
				centerp.x + centerp.radius,
				centerp.y,
				centerp.x + centerp.radius,
				centerp.y
			);

			m_vCenterPoints.erase(m_vCenterPoints.begin() + i);//(&m_vCenterPoints.at(i));
			i--;
			bdelete = true;
		}
	}
	if (bdelete) {
		msg.Format(TEXT("去掉潜在的错误（粗红笔）后数目=%d"), m_vCenterPoints.size());
		MessageBox(msg);
	}
	bdelete = false;
	pdc->SelectObject(Bluepen1);
	// 去掉潜在的错误(同两个圆相交,并且不相交的部分是噪声)
	for (unsigned int i = 0; i < m_vCenterPoints.size(); i++)
	{
		tocheck.clear();
		x0 = m_vCenterPoints.at(i).x;
		y0 = m_vCenterPoints.at(i).y;
		r0 = m_vCenterPoints.at(i).radius;
		for (unsigned int j = 0; j < m_vCenterPoints.size(); j++)
		{
			if (i == j)
				continue;
			int x = m_vCenterPoints.at(j).x;
			int y = m_vCenterPoints.at(j).y;
			r = m_vCenterPoints.at(j).radius;
			if (DISTANCE(x0, y0, x, y) < abs(r0 + r)) // 相交
			{
				pt.x = x; pt.y = y; pt.radius = r;
				tocheck.push_back(pt);
			}
		}
		unsigned int size = (unsigned int)tocheck.size();
		if (size > 0) // 同两个以上的圆相交
		{
			total = 0;
			for (tx = x0 - r0; tx < x0 + r0; tx++)
				for (ty = y0 - r0; ty < y0 + r0; ty++)
				{
					if (DISTANCE(x0, y0, tx, ty) < r0) // 所有圆内部的点
					{
						if (tx<1 || tx>lWidth-1|| ty<1 || ty>lHeight)
							continue;
						isok = true;
						for (unsigned int n = 0; n < size; n++)
						{
							pt = tocheck.at(n);// 取得
							if (DISTANCE(tx, ty, pt.x, pt.y) < pt.radius)
							{
								isok = false;
								break;
							}
						}
						if (isok) // 同所有的圆都不相交的部分
						{
							total++;
						}
					}
				}
			if (total < Pi * r0 * r0 * .5) // need adjust 50%
			{
				CENTER_POINT centerp;
				centerp = m_vCenterPoints.at(i);
				Arc(pdc->m_hDC,
					centerp.x - centerp.radius,
					centerp.y - centerp.radius,
					centerp.x + centerp.radius,
					centerp.y + centerp.radius,
					centerp.x + centerp.radius,
					centerp.y,
					centerp.x + centerp.radius,
					centerp.y
				);
				m_vCenterPoints.erase(m_vCenterPoints.begin() + i);//(&m_vCenterPoints.at(i));
				i--; bdelete = true;
			}
		}
	}

	if (bdelete) 
	{
		msg.Format(TEXT("去掉同两个圆相交错误（粗蓝笔）后数目=%d"), m_vCenterPoints.size());
		MessageBox(msg);
	}

	DeleteObject(Redpen);
	DeleteObject(Greenpen);
	DeleteObject(Bluepen);


}

void CImgProcView::MarkIt(int i, int j)
{

	if (j == 1 || j == lHeight - 2 || i == 1 || i == lWidth - 2) // 最边上的不用处理
	{
		return;
	}

	unsigned char* lpSrc;

	lpSrc = (unsigned char*)mpImage + lLineBytes * (lHeight - 1 - j) + i;

	*(lpSrc) |= VISITED; //每进入该函数，给它一个访问标志


	// 如何判断是否保存当前像素点，即把它当作中心点
	// 当前像素上下左右以及左上、左下、右上及右下
	// 八个点都不是mark，只有边缘或者背景，则把该像素当成中心点

	if (!(*(lpSrc - 1) & VISITED) && *(lpSrc - 1) & MARKED)
	{
		if (*(lpSrc - 1) & EDGEPOINT) // 并且是边缘
		{
			MarkIt(i - 1, j);		  // 左边
		}
		else
		{
			// 一旦附近是mark点，则m_bFullEdge赋值为false,不保存。 
			m_bFullEdge = false;
		}
	}

	if (!(*(lpSrc + 1) & VISITED) && *(lpSrc + 1) & MARKED)
	{
		if (*(lpSrc + 1) & EDGEPOINT) // 并且是边缘
		{
			MarkIt(i + 1, j);		  // 右边
		}
		else
		{
			m_bFullEdge = false;
		}
	}

	if (!(*(lpSrc + lLineBytes) & VISITED) &&	// 没有访问过
		*(lpSrc + lLineBytes) & MARKED)	// 标志了
	{
		if (*(lpSrc + lLineBytes) & EDGEPOINT)		// 并且是边缘
			MarkIt(i, j - 1); // 上面
		else
			m_bFullEdge = false;
	}

	if (!(*(lpSrc - lLineBytes) & VISITED) &&	// 没有访问过
		*(lpSrc - lLineBytes) & MARKED)	// 标志了
	{
		if (*(lpSrc - lLineBytes) & EDGEPOINT)		// 并且是边缘
			MarkIt(i, j + 1); // 下面
		else
			m_bFullEdge = false;
	}

	if (!(*(lpSrc + lLineBytes - 1) & VISITED) &&	// 没有访问过
		*(lpSrc + lLineBytes - 1) & MARKED)		// 标志了
	{
		if (*(lpSrc + lLineBytes - 1) & EDGEPOINT)		// 并且是边缘
			MarkIt(i - 1, j - 1); // 左上
		else
			m_bFullEdge = false;
	}

	if (!(*(lpSrc - lLineBytes - 1) & VISITED) &&	// 没有访问过
		*(lpSrc - lLineBytes - 1) & MARKED)		// 标志了
	{
		if (*(lpSrc - lLineBytes - 1) & EDGEPOINT)		// 并且是边缘
			MarkIt(i - 1, j + 1); // 左下
		else
			m_bFullEdge = false;
	}

	if (!(*(lpSrc + lLineBytes + 1) & VISITED) &&	// 没有访问过
		*(lpSrc + lLineBytes + 1) & MARKED)		// 标志了
	{
		if (*(lpSrc + lLineBytes + 1) & EDGEPOINT)		// 并且是边缘
			MarkIt(i + 1, j - 1); // 右上
		else
			m_bFullEdge = false;
	}

	if (!(*(lpSrc - lLineBytes + 1) & VISITED) &&	// 没有访问过
		*(lpSrc - lLineBytes + 1) & MARKED)		// 标志了
	{
		if (*(lpSrc - lLineBytes + 1) & EDGEPOINT)		// 并且是边缘
			MarkIt(i + 1, j + 1); // 右下
		else
			m_bFullEdge = false;
	}



}

void CImgProcView::SaveIt(int i, int j, int radius)
{

	if (j == 1 || j == lHeight - 2 || i == 1 || i == lWidth - 2) // 最边上的不用处理
	{
		return;
	}

	unsigned char* lpSrc;

	lpSrc = (unsigned char*)mpImage + lLineBytes * (lHeight - 1 - j) + i;
	
	// 执行mark函数时添加了访问标记
	*lpSrc &= NO_VISITED;//清楚访问标志位，访问过才进栈 NO_VISITED=0xfe
	
	if (!(*lpSrc & CENTERED))  // 没有中心点标记时
	{
		CENTER_POINT pt;
		pt.x = i;
		pt.y = j;
		pt.radius = radius;
		points_temp.push_back(pt);
		*lpSrc |= CENTERED;
	}

	// 执行mark函数时添加了访问标记
	//*lpSrc &= NO_VISITED;//清楚访问标志位，访问过才进栈 NO_VISITED=0xfe

	// 下面保存操作时 可能多个细胞收缩多次，最终各个细胞的中心点 收缩成
	// 分散的点或者一条线

	if (*(lpSrc - 1) & VISITED)   
	{
		SaveIt(i - 1, j, radius);
	}
	if (*(lpSrc + 1) & VISITED)
	{
		SaveIt(i + 1, j, radius);
	}
	if (*(lpSrc + lLineBytes) & VISITED)
	{
		SaveIt(i, j - 1, radius);
	}
	if (*(lpSrc - lLineBytes) & VISITED)
	{
		SaveIt(i, j + 1, radius);
	}

	if (*(lpSrc - lLineBytes + 1) & VISITED)
	{
		SaveIt(i + 1, j + 1, radius);
	}
	if (*(lpSrc + lLineBytes - 1) & VISITED)
	{
		SaveIt(i - 1, j + 1, radius);
	}
	if (*(lpSrc - lLineBytes + 1) & VISITED)
	{
		SaveIt(i + 1, j - 1, radius);
	}
	if (*(lpSrc - lLineBytes - 1) & VISITED)
	{
		SaveIt(i - 1, j - 1, radius);
	}

}

void CImgProcView::CalcCenterArea(int i, int j)
{
	unsigned char* lpSrc;
	lpSrc = (unsigned char*)mpImage + lLineBytes * (lHeight - 1 - j) + i;

	if (j == 0 || j == lHeight-1 || i == 0 || i == lWidth-1) // 最边上的不用处理
	{
		return;
	}

	tot_area++;  //每次进入此函数就开始自加     
	tot_x += i;
	tot_y += j;

	*lpSrc &= NO_CENTER; // 清楚中心点标记位

	for (unsigned int n = 0; n < points_temp.size(); n++)
	{
		if (points_temp.at(n).x == i && points_temp.at(n).y == j)
		{
			// 由于max_radius该函数调用的上面直接赋值0了
			// 所以下面进行了一个判断赋值
			// 由于递归，每次进入该函数，相当于都和上一次max_radius比较
			// 把大的值半径赋值给max_radius;

			if (points_temp.at(n).radius > max_radius)
			{
				max_radius = points_temp.at(n).radius;
			}
			break;
		}
	}

	if (*(lpSrc - 1) & CENTERED)
	{
		CalcCenterArea(i - 1, j);
	}
	if (*(lpSrc + 1) & CENTERED)
	{
		CalcCenterArea(i + 1, j);
	}
	if (*(lpSrc + lLineBytes) & CENTERED)
	{
		CalcCenterArea(i, j - 1);
	}
	if (*(lpSrc - lLineBytes) & CENTERED)
	{
		CalcCenterArea(i, j + 1);
	}

	if (*(lpSrc - lLineBytes + 1) & CENTERED)
	{
		CalcCenterArea(i + 1, j + 1);
	}
	if (*(lpSrc - lLineBytes - 1) & CENTERED)
	{
		CalcCenterArea(i - 1, j + 1);
	}
	if (*(lpSrc + lLineBytes + 1) & CENTERED)
	{
		CalcCenterArea(i + 1, j - 1);
	}
	if (*(lpSrc + lLineBytes - 1) & CENTERED)
	{
		CalcCenterArea(i - 1, j - 1);
	}

}

void CImgProcView::OnCellprocessCount()
{
	// TODO: 在此添加命令处理程序代码

	LoadBmp();
	double tota, totr;
	tota = 0; totr = 0;
	double m_nHistHSI[256 * 3];
	unsigned char* lpSrc;
	for (int i = 0; i < 256 * 3; i++)
	{
		// 清零
		m_nHistHSI[i] = 0;
	}


	for (unsigned int i = 0; i < m_vCenterPoints.size(); i++)
	{
		tota += m_vCenterPoints.at(i).radius * m_vCenterPoints.at(i).radius * 3.14f;
		totr += m_vCenterPoints.at(i).radius;

		//get Hsi 	
		for (int m = m_vCenterPoints.at(i).x - m_vCenterPoints.at(i).radius; m < m_vCenterPoints.at(i).x + m_vCenterPoints.at(i).radius; m++)
			for (int n = m_vCenterPoints.at(i).y - m_vCenterPoints.at(i).radius; n < m_vCenterPoints.at(i).y + m_vCenterPoints.at(i).radius; n++)
			{
				if (m >= 0&& m <= lWidth-1 && n >= 0 && n <=lHeight-1)
				{
					if (DISTANCE(m, n, m_vCenterPoints.at(i).x, m_vCenterPoints.at(i).y) <= m_vCenterPoints.at(i).radius)
					{
						lpSrc = (unsigned char*)mpImage + lLineBytes * (lHeight - 1 - n) + m * 3;
						RGB Rgb;
						HSI Hsi;
						Rgb.b = *lpSrc; Rgb.g = *(lpSrc + 1); Rgb.r = *(lpSrc + 2);
						RgbtoHsi(&Rgb, &Hsi);
						unsigned int H, S, I;
						H = (unsigned int)(Hsi.Hue / 360.0 * 255.0);
						S = (unsigned int)(Hsi.Saturation * 255.0);
						I = (unsigned int)(Hsi.Intensity * 255.0);

						// 计数加1
						m_nHistHSI[H]++;//H
						m_nHistHSI[256 + S]++;//S
						m_nHistHSI[256 * 2 + I]++;//I
					}
				}
			}

	}
	int min[3];
	int max[3];
	min[0] = min[1] = min[2] = 255;
	max[0] = max[1] = max[2] = 0;
	double add;
	for (int j = 0; j < 3; j++)
	{
		add = 0;
		for (int i = 0; i < 256; i++)
		{
			// 清零
			add += m_nHistHSI[j * 256 + i];
			if (add > tota / 20) {//>5%
				min[j] = i;
				i = 256;//out
			}

		}
	}
	for (int j = 0; j < 3; j++)
	{
		add = 0;
		for (int i = 255; i > 0; i--)
		{
			// 清零
			add += m_nHistHSI[j * 255 + i];
			if (add > tota / 20) {//>5%
				max[j] = i;
				i = 0;//out
			}

		}
	}
	Invalidate(true);
	MessageBox(TEXT("ReLoad Image"));

	CString msg;

	/*
		CMainFrame* pFrame = (CMainFrame*)AfxGetApp()->m_pMainWnd;
		CStatusBar* pStatus = &pFrame->m_wndStatusBar;
		if (pStatus)
			pStatus->SetPaneText(0, msg);
	*/

	//归一化
	for (int j = 0; j < 3; j++)
	{
		double max = 0;
		for (int i = 0; i < 256; i++)
			if (max < m_nHistHSI[j * 256 + i])
				max = m_nHistHSI[j * 256 + i];
		for (int i = 0; i < 256; i++)
			m_nHistHSI[j * 256 + i] /= max;
	}
	CDC* pdc = GetDC();
	CPen	Redpen;
	Redpen.CreatePen(PS_DOT, 1, RGB(255, 0, 0));

	pdc->SelectObject(Redpen);
	for (unsigned int i = 0; i < m_vCenterPoints.size(); i++) {
		Arc(pdc->m_hDC,
			m_vCenterPoints.at(i).x - m_vCenterPoints.at(i).radius,
			m_vCenterPoints.at(i).y - m_vCenterPoints.at(i).radius,
			m_vCenterPoints.at(i).x + m_vCenterPoints.at(i).radius,
			m_vCenterPoints.at(i).y + m_vCenterPoints.at(i).radius,
			m_vCenterPoints.at(i).x + m_vCenterPoints.at(i).radius,
			m_vCenterPoints.at(i).y,
			m_vCenterPoints.at(i).x + m_vCenterPoints.at(i).radius,
			m_vCenterPoints.at(i).y
		);
	}
	//msg.Format(L"共有%d个细胞,平均半径%d,平均面积%d  : H(%3.1f,%3.1f) S(%3.2f,%3.2f) I(%3.2f,%3.2f)",
	//	m_vCenterPoints.size(),
	//	(int)(totr / m_vCenterPoints.size() + .5),
	//	(int)(tota / m_vCenterPoints.size() + .5),
	//	360.0 * min[0] / 255.0, 360.0 * max[0] / 255.0,
	//	1.0 * min[1] / 255.0, 1.0 * max[1] / 255.0,
	//	1.0 * min[2] / 255.0, 1.0 * max[2] / 255.0);

	msg.Format(L"共有%d个细胞,平均半径%d,平均面积%d  ",
		m_vCenterPoints.size(),
		(int)(totr / m_vCenterPoints.size() + .5),
		(int)(tota / m_vCenterPoints.size() + .5));



	MessageBox(msg);
	DeleteObject(Redpen);

}


