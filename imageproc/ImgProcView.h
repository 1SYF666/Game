
// ImgProcView.h: CImgProcView 类的接口
//

#pragma once

#include "DispalyDialog.h"
#include "HSIDialog.h"
#include "HSI.h"
#include <stack> //栈--先进后出
#include<vector> //动态数组
using namespace std;

struct CENTER_POINT
{
	int x;
	int y;
	int radius;
};


class CImgProcView : public CView
{
protected: // 仅从序列化创建
	CImgProcView() noexcept;
	DECLARE_DYNCREATE(CImgProcView)

// 特性
public:
	CImgProcDoc* GetDocument() const;


// 操作
public:
 	//

	




// 重写
public:
	virtual void OnDraw(CDC* pDC);  // 重写以绘制该视图
	virtual BOOL PreCreateWindow(CREATESTRUCT& cs);

protected:
	virtual BOOL OnPreparePrinting(CPrintInfo* pInfo);
	virtual void OnBeginPrinting(CDC* pDC, CPrintInfo* pInfo);
	virtual void OnEndPrinting(CDC* pDC, CPrintInfo* pInfo);

// 实现
public:
	virtual ~CImgProcView();
#ifdef _DEBUG
	virtual void AssertValid() const;
	virtual void Dump(CDumpContext& dc) const;
#endif

protected:

// 生成的消息映射函数
protected:
	DECLARE_MESSAGE_MAP()
public:

	afx_msg void OnMouseMove(UINT nFlags, CPoint point);
	virtual void OnInitialUpdate();
	afx_msg void OnHistgramRgb();
	afx_msg void OnHistgramHsi();
	afx_msg void OnCellprocessMark();
	afx_msg void OnCellprocessTwovalue();
	afx_msg void OnCellprocessFillholes();
//
	void ProcessFillHoles(int wd, int ht);
	void GenEdge();
	void GenEdge4();

	void MarkIt(int i, int j);
	void SaveIt(int i, int j, int radius);
	void CalcCenterArea(int i, int j);

	bool LoadBmp();


	afx_msg void OnCellprocessShrink();

	afx_msg void OnCellprocessFindcenter();
	afx_msg void OnCellprocessCount();
};

#ifndef _DEBUG  // ImgProcView.cpp 中的调试版本
inline CImgProcDoc* CImgProcView::GetDocument() const
   { return reinterpret_cast<CImgProcDoc*>(m_pDocument); }
#endif

