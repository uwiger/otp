%%
%% %CopyrightBegin%
%% 
%% Copyright Ericsson AB 2008-2009. All Rights Reserved.
%% 
%% The contents of this file are subject to the Erlang Public License,
%% Version 1.1, (the "License"); you may not use this file except in
%% compliance with the License. You should have received a copy of the
%% Erlang Public License along with this software. If not, it can be
%% retrieved online at http://www.erlang.org/.
%% 
%% Software distributed under the License is distributed on an "AS IS"
%% basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
%% the License for the specific language governing rights and limitations
%% under the License.
%% 
%% %CopyrightEnd%
%% This file is generated DO NOT EDIT

%% @doc See external documentation: <a href="http://www.wxwidgets.org/manuals/stable/wx_wxbuffereddc.html">wxBufferedDC</a>.
%% <p>This class is derived (and can use functions) from: 
%% <br />{@link wxMemoryDC}
%% <br />{@link wxDC}
%% </p>
%% @type wxBufferedDC().  An object reference, The representation is internal
%% and can be changed without notice. It can't be used for comparsion
%% stored on disc or distributed for use on other nodes.

-module(wxBufferedDC).
-include("wxe.hrl").
-export([destroy/1,init/2,init/3,init/4,new/0,new/1,new/2,new/3]).

%% inherited exports
-export([blit/5,blit/6,calcBoundingBox/3,clear/1,computeScaleAndOrigin/1,crossHair/2,
  destroyClippingRegion/1,deviceToLogicalX/2,deviceToLogicalXRel/2,
  deviceToLogicalY/2,deviceToLogicalYRel/2,drawArc/4,drawBitmap/3,drawBitmap/4,
  drawCheckMark/2,drawCircle/3,drawEllipse/2,drawEllipse/3,drawEllipticArc/5,
  drawIcon/3,drawLabel/3,drawLabel/4,drawLine/3,drawLines/2,drawLines/3,
  drawPoint/2,drawPolygon/2,drawPolygon/3,drawRectangle/2,drawRectangle/3,
  drawRotatedText/4,drawRoundedRectangle/3,drawRoundedRectangle/4,
  drawText/3,endDoc/1,endPage/1,floodFill/3,floodFill/4,getBackground/1,
  getBackgroundMode/1,getBrush/1,getCharHeight/1,getCharWidth/1,getClippingBox/2,
  getFont/1,getLayoutDirection/1,getLogicalFunction/1,getMapMode/1,
  getMultiLineTextExtent/2,getMultiLineTextExtent/3,getPPI/1,getPartialTextExtents/3,
  getPen/1,getPixel/3,getSize/1,getSizeMM/1,getTextBackground/1,getTextExtent/2,
  getTextExtent/3,getTextForeground/1,getUserScale/1,gradientFillConcentric/4,
  gradientFillConcentric/5,gradientFillLinear/4,gradientFillLinear/5,
  isOk/1,logicalToDeviceX/2,logicalToDeviceXRel/2,logicalToDeviceY/2,
  logicalToDeviceYRel/2,maxX/1,maxY/1,minX/1,minY/1,parent_class/1,resetBoundingBox/1,
  selectObject/2,selectObjectAsSource/2,setAxisOrientation/3,setBackground/2,
  setBackgroundMode/2,setBrush/2,setClippingRegion/2,setClippingRegion/3,
  setDeviceOrigin/3,setFont/2,setLayoutDirection/2,setLogicalFunction/2,
  setMapMode/2,setPalette/2,setPen/2,setTextBackground/2,setTextForeground/2,
  setUserScale/3,startDoc/2,startPage/1]).

%% @hidden
parent_class(wxMemoryDC) -> true;
parent_class(wxDC) -> true;
parent_class(_Class) -> erlang:error({badtype, ?MODULE}).

%% @spec () -> wxBufferedDC()
%% @doc See <a href="http://www.wxwidgets.org/manuals/stable/wx_wxbuffereddc.html#wxbuffereddcwxbuffereddc">external documentation</a>.
new() ->
  wxe_util:construct(?wxBufferedDC_new_0,
  <<>>).

%% @spec (Dc::wxDC:wxDC()) -> wxBufferedDC()
%% @equiv new(Dc, [])
new(Dc)
 when is_record(Dc, wx_ref) ->
  new(Dc, []).

%% @spec (Dc::wxDC:wxDC(),X::term()) -> wxBufferedDC()
%% @doc See <a href="http://www.wxwidgets.org/manuals/stable/wx_wxbuffereddc.html#wxbuffereddcwxbuffereddc">external documentation</a>.
%% <br /> Alternatives: 
%% <p><c>
%% new(Dc::wxDC:wxDC(), Area::{W::integer(),H::integer()}) -> new(Dc,Area, []) </c></p>
%% <p><c>
%% new(Dc::wxDC:wxDC(), [Option]) -> wxBufferedDC() </c>
%%<br /> Option = {buffer, wxBitmap:wxBitmap()} | {style, integer()}
%% </p>

new(Dc,Area={AreaW,AreaH})
 when is_record(Dc, wx_ref),is_integer(AreaW),is_integer(AreaH) ->
  new(Dc,Area, []);
new(#wx_ref{type=DcT,ref=DcRef}, Options)
 when is_list(Options) ->
  ?CLASS(DcT,wxDC),
  MOpts = fun({buffer, #wx_ref{type=BufferT,ref=BufferRef}}, Acc) ->   ?CLASS(BufferT,wxBitmap),[<<1:32/?UI,BufferRef:32/?UI>>|Acc];
          ({style, Style}, Acc) -> [<<2:32/?UI,Style:32/?UI>>|Acc];
          (BadOpt, _) -> erlang:error({badoption, BadOpt}) end,
  BinOpt = list_to_binary(lists:foldl(MOpts, [<<0:32>>], Options)),
  wxe_util:construct(?wxBufferedDC_new_2,
  <<DcRef:32/?UI, 0:32,BinOpt/binary>>).

%% @spec (Dc::wxDC:wxDC(), Area::{W::integer(),H::integer()}, [Option]) -> wxBufferedDC()
%% Option = {style, integer()}
%% @doc See <a href="http://www.wxwidgets.org/manuals/stable/wx_wxbuffereddc.html#wxbuffereddcwxbuffereddc">external documentation</a>.
new(#wx_ref{type=DcT,ref=DcRef},{AreaW,AreaH}, Options)
 when is_integer(AreaW),is_integer(AreaH),is_list(Options) ->
  ?CLASS(DcT,wxDC),
  MOpts = fun({style, Style}, Acc) -> [<<1:32/?UI,Style:32/?UI>>|Acc];
          (BadOpt, _) -> erlang:error({badoption, BadOpt}) end,
  BinOpt = list_to_binary(lists:foldl(MOpts, [<<0:32>>], Options)),
  wxe_util:construct(?wxBufferedDC_new_3,
  <<DcRef:32/?UI,AreaW:32/?UI,AreaH:32/?UI, 0:32,BinOpt/binary>>).

%% @spec (This::wxBufferedDC(), Dc::wxDC:wxDC()) -> ok
%% @equiv init(This,Dc, [])
init(This,Dc)
 when is_record(This, wx_ref),is_record(Dc, wx_ref) ->
  init(This,Dc, []).

%% @spec (This::wxBufferedDC(),Dc::wxDC:wxDC(),X::term()) -> ok
%% @doc See <a href="http://www.wxwidgets.org/manuals/stable/wx_wxbuffereddc.html#wxbuffereddcinit">external documentation</a>.
%% <br /> Alternatives: 
%% <p><c>
%% init(This::wxBufferedDC(), Dc::wxDC:wxDC(), Area::{W::integer(),H::integer()}) -> init(This,Dc,Area, []) </c></p>
%% <p><c>
%% init(This::wxBufferedDC(), Dc::wxDC:wxDC(), [Option]) -> ok </c>
%%<br /> Option = {buffer, wxBitmap:wxBitmap()} | {style, integer()}
%% </p>

init(This,Dc,Area={AreaW,AreaH})
 when is_record(This, wx_ref),is_record(Dc, wx_ref),is_integer(AreaW),is_integer(AreaH) ->
  init(This,Dc,Area, []);
init(#wx_ref{type=ThisT,ref=ThisRef},#wx_ref{type=DcT,ref=DcRef}, Options)
 when is_list(Options) ->
  ?CLASS(ThisT,wxBufferedDC),
  ?CLASS(DcT,wxDC),
  MOpts = fun({buffer, #wx_ref{type=BufferT,ref=BufferRef}}, Acc) ->   ?CLASS(BufferT,wxBitmap),[<<1:32/?UI,BufferRef:32/?UI>>|Acc];
          ({style, Style}, Acc) -> [<<2:32/?UI,Style:32/?UI>>|Acc];
          (BadOpt, _) -> erlang:error({badoption, BadOpt}) end,
  BinOpt = list_to_binary(lists:foldl(MOpts, [<<0:32>>], Options)),
  wxe_util:cast(?wxBufferedDC_Init_2,
  <<ThisRef:32/?UI,DcRef:32/?UI, BinOpt/binary>>).

%% @spec (This::wxBufferedDC(), Dc::wxDC:wxDC(), Area::{W::integer(),H::integer()}, [Option]) -> ok
%% Option = {style, integer()}
%% @doc See <a href="http://www.wxwidgets.org/manuals/stable/wx_wxbuffereddc.html#wxbuffereddcinit">external documentation</a>.
init(#wx_ref{type=ThisT,ref=ThisRef},#wx_ref{type=DcT,ref=DcRef},{AreaW,AreaH}, Options)
 when is_integer(AreaW),is_integer(AreaH),is_list(Options) ->
  ?CLASS(ThisT,wxBufferedDC),
  ?CLASS(DcT,wxDC),
  MOpts = fun({style, Style}, Acc) -> [<<1:32/?UI,Style:32/?UI>>|Acc];
          (BadOpt, _) -> erlang:error({badoption, BadOpt}) end,
  BinOpt = list_to_binary(lists:foldl(MOpts, [<<0:32>>], Options)),
  wxe_util:cast(?wxBufferedDC_Init_3,
  <<ThisRef:32/?UI,DcRef:32/?UI,AreaW:32/?UI,AreaH:32/?UI, BinOpt/binary>>).

%% @spec (This::wxBufferedDC()) -> ok
%% @doc Destroys this object, do not use object again
destroy(Obj=#wx_ref{type=Type}) -> 
  ?CLASS(Type,wxBufferedDC),
  wxe_util:destroy(?DESTROY_OBJECT,Obj),
  ok.
 %% From wxMemoryDC 
%% @hidden
selectObjectAsSource(This,Bmp) -> wxMemoryDC:selectObjectAsSource(This,Bmp).
%% @hidden
selectObject(This,Bmp) -> wxMemoryDC:selectObject(This,Bmp).
 %% From wxDC 
%% @hidden
startPage(This) -> wxDC:startPage(This).
%% @hidden
startDoc(This,Message) -> wxDC:startDoc(This,Message).
%% @hidden
setUserScale(This,X,Y) -> wxDC:setUserScale(This,X,Y).
%% @hidden
setTextForeground(This,Colour) -> wxDC:setTextForeground(This,Colour).
%% @hidden
setTextBackground(This,Colour) -> wxDC:setTextBackground(This,Colour).
%% @hidden
setPen(This,Pen) -> wxDC:setPen(This,Pen).
%% @hidden
setPalette(This,Palette) -> wxDC:setPalette(This,Palette).
%% @hidden
setMapMode(This,Mode) -> wxDC:setMapMode(This,Mode).
%% @hidden
setLogicalFunction(This,Function) -> wxDC:setLogicalFunction(This,Function).
%% @hidden
setLayoutDirection(This,Dir) -> wxDC:setLayoutDirection(This,Dir).
%% @hidden
setFont(This,Font) -> wxDC:setFont(This,Font).
%% @hidden
setDeviceOrigin(This,X,Y) -> wxDC:setDeviceOrigin(This,X,Y).
%% @hidden
setClippingRegion(This,Pt,Sz) -> wxDC:setClippingRegion(This,Pt,Sz).
%% @hidden
setClippingRegion(This,Region) -> wxDC:setClippingRegion(This,Region).
%% @hidden
setBrush(This,Brush) -> wxDC:setBrush(This,Brush).
%% @hidden
setBackgroundMode(This,Mode) -> wxDC:setBackgroundMode(This,Mode).
%% @hidden
setBackground(This,Brush) -> wxDC:setBackground(This,Brush).
%% @hidden
setAxisOrientation(This,XLeftRight,YBottomUp) -> wxDC:setAxisOrientation(This,XLeftRight,YBottomUp).
%% @hidden
resetBoundingBox(This) -> wxDC:resetBoundingBox(This).
%% @hidden
isOk(This) -> wxDC:isOk(This).
%% @hidden
minY(This) -> wxDC:minY(This).
%% @hidden
minX(This) -> wxDC:minX(This).
%% @hidden
maxY(This) -> wxDC:maxY(This).
%% @hidden
maxX(This) -> wxDC:maxX(This).
%% @hidden
logicalToDeviceYRel(This,Y) -> wxDC:logicalToDeviceYRel(This,Y).
%% @hidden
logicalToDeviceY(This,Y) -> wxDC:logicalToDeviceY(This,Y).
%% @hidden
logicalToDeviceXRel(This,X) -> wxDC:logicalToDeviceXRel(This,X).
%% @hidden
logicalToDeviceX(This,X) -> wxDC:logicalToDeviceX(This,X).
%% @hidden
gradientFillLinear(This,Rect,InitialColour,DestColour, Options) -> wxDC:gradientFillLinear(This,Rect,InitialColour,DestColour, Options).
%% @hidden
gradientFillLinear(This,Rect,InitialColour,DestColour) -> wxDC:gradientFillLinear(This,Rect,InitialColour,DestColour).
%% @hidden
gradientFillConcentric(This,Rect,InitialColour,DestColour,CircleCenter) -> wxDC:gradientFillConcentric(This,Rect,InitialColour,DestColour,CircleCenter).
%% @hidden
gradientFillConcentric(This,Rect,InitialColour,DestColour) -> wxDC:gradientFillConcentric(This,Rect,InitialColour,DestColour).
%% @hidden
getUserScale(This) -> wxDC:getUserScale(This).
%% @hidden
getTextForeground(This) -> wxDC:getTextForeground(This).
%% @hidden
getTextExtent(This,String, Options) -> wxDC:getTextExtent(This,String, Options).
%% @hidden
getTextExtent(This,String) -> wxDC:getTextExtent(This,String).
%% @hidden
getTextBackground(This) -> wxDC:getTextBackground(This).
%% @hidden
getSizeMM(This) -> wxDC:getSizeMM(This).
%% @hidden
getSize(This) -> wxDC:getSize(This).
%% @hidden
getPPI(This) -> wxDC:getPPI(This).
%% @hidden
getPixel(This,Pt,Col) -> wxDC:getPixel(This,Pt,Col).
%% @hidden
getPen(This) -> wxDC:getPen(This).
%% @hidden
getPartialTextExtents(This,Text,Widths) -> wxDC:getPartialTextExtents(This,Text,Widths).
%% @hidden
getMultiLineTextExtent(This,String, Options) -> wxDC:getMultiLineTextExtent(This,String, Options).
%% @hidden
getMultiLineTextExtent(This,String) -> wxDC:getMultiLineTextExtent(This,String).
%% @hidden
getMapMode(This) -> wxDC:getMapMode(This).
%% @hidden
getLogicalFunction(This) -> wxDC:getLogicalFunction(This).
%% @hidden
getLayoutDirection(This) -> wxDC:getLayoutDirection(This).
%% @hidden
getFont(This) -> wxDC:getFont(This).
%% @hidden
getClippingBox(This,Rect) -> wxDC:getClippingBox(This,Rect).
%% @hidden
getCharWidth(This) -> wxDC:getCharWidth(This).
%% @hidden
getCharHeight(This) -> wxDC:getCharHeight(This).
%% @hidden
getBrush(This) -> wxDC:getBrush(This).
%% @hidden
getBackgroundMode(This) -> wxDC:getBackgroundMode(This).
%% @hidden
getBackground(This) -> wxDC:getBackground(This).
%% @hidden
floodFill(This,Pt,Col, Options) -> wxDC:floodFill(This,Pt,Col, Options).
%% @hidden
floodFill(This,Pt,Col) -> wxDC:floodFill(This,Pt,Col).
%% @hidden
endPage(This) -> wxDC:endPage(This).
%% @hidden
endDoc(This) -> wxDC:endDoc(This).
%% @hidden
drawText(This,Text,Pt) -> wxDC:drawText(This,Text,Pt).
%% @hidden
drawRoundedRectangle(This,Pt,Sz,Radius) -> wxDC:drawRoundedRectangle(This,Pt,Sz,Radius).
%% @hidden
drawRoundedRectangle(This,R,Radius) -> wxDC:drawRoundedRectangle(This,R,Radius).
%% @hidden
drawRotatedText(This,Text,Pt,Angle) -> wxDC:drawRotatedText(This,Text,Pt,Angle).
%% @hidden
drawRectangle(This,Pt,Sz) -> wxDC:drawRectangle(This,Pt,Sz).
%% @hidden
drawRectangle(This,Rect) -> wxDC:drawRectangle(This,Rect).
%% @hidden
drawPoint(This,Pt) -> wxDC:drawPoint(This,Pt).
%% @hidden
drawPolygon(This,Points, Options) -> wxDC:drawPolygon(This,Points, Options).
%% @hidden
drawPolygon(This,Points) -> wxDC:drawPolygon(This,Points).
%% @hidden
drawLines(This,Points, Options) -> wxDC:drawLines(This,Points, Options).
%% @hidden
drawLines(This,Points) -> wxDC:drawLines(This,Points).
%% @hidden
drawLine(This,Pt1,Pt2) -> wxDC:drawLine(This,Pt1,Pt2).
%% @hidden
drawLabel(This,Text,Rect, Options) -> wxDC:drawLabel(This,Text,Rect, Options).
%% @hidden
drawLabel(This,Text,Rect) -> wxDC:drawLabel(This,Text,Rect).
%% @hidden
drawIcon(This,Icon,Pt) -> wxDC:drawIcon(This,Icon,Pt).
%% @hidden
drawEllipticArc(This,Pt,Sz,Sa,Ea) -> wxDC:drawEllipticArc(This,Pt,Sz,Sa,Ea).
%% @hidden
drawEllipse(This,Pt,Sz) -> wxDC:drawEllipse(This,Pt,Sz).
%% @hidden
drawEllipse(This,Rect) -> wxDC:drawEllipse(This,Rect).
%% @hidden
drawCircle(This,Pt,Radius) -> wxDC:drawCircle(This,Pt,Radius).
%% @hidden
drawCheckMark(This,Rect) -> wxDC:drawCheckMark(This,Rect).
%% @hidden
drawBitmap(This,Bmp,Pt, Options) -> wxDC:drawBitmap(This,Bmp,Pt, Options).
%% @hidden
drawBitmap(This,Bmp,Pt) -> wxDC:drawBitmap(This,Bmp,Pt).
%% @hidden
drawArc(This,Pt1,Pt2,Centre) -> wxDC:drawArc(This,Pt1,Pt2,Centre).
%% @hidden
deviceToLogicalYRel(This,Y) -> wxDC:deviceToLogicalYRel(This,Y).
%% @hidden
deviceToLogicalY(This,Y) -> wxDC:deviceToLogicalY(This,Y).
%% @hidden
deviceToLogicalXRel(This,X) -> wxDC:deviceToLogicalXRel(This,X).
%% @hidden
deviceToLogicalX(This,X) -> wxDC:deviceToLogicalX(This,X).
%% @hidden
destroyClippingRegion(This) -> wxDC:destroyClippingRegion(This).
%% @hidden
crossHair(This,Pt) -> wxDC:crossHair(This,Pt).
%% @hidden
computeScaleAndOrigin(This) -> wxDC:computeScaleAndOrigin(This).
%% @hidden
clear(This) -> wxDC:clear(This).
%% @hidden
calcBoundingBox(This,X,Y) -> wxDC:calcBoundingBox(This,X,Y).
%% @hidden
blit(This,DestPt,Sz,Source,SrcPt, Options) -> wxDC:blit(This,DestPt,Sz,Source,SrcPt, Options).
%% @hidden
blit(This,DestPt,Sz,Source,SrcPt) -> wxDC:blit(This,DestPt,Sz,Source,SrcPt).
