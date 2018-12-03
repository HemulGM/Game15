unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, XPMan, ExtCtrls, pngextra, pngimage;

type
  TFormMain = class(TForm)
    ButtonClose: TPNGButton;
    LabelFCount: TLabel;
    ButtonHide: TPNGButton;
    LabelTime: TLabel;
    ImageTime: TImage;
    ImageBombLeft: TImage;
    ButtonNew: TPNGButton;
    ButtonAbout: TPNGButton;
    ButtonOption: TPNGButton;
    DrawGridPoly: TDrawGrid;
    XPManifest: TXPManifest;
    TimerTime: TTimer;
    ImageBG: TImage;
    ButtonHelp: TPNGButton;
    procedure DrawGridPolyDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure FormCreate(Sender: TObject);
    procedure DrawGridPolyMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DrawGridPolyMouseWheelDown(Sender: TObject;
      Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure DrawGridPolyMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure ButtonCloseClick(Sender: TObject);
    procedure ImageBGMouseEnter(Sender: TObject);
    procedure ImageBGMouseLeave(Sender: TObject);
    procedure ButtonHideClick(Sender: TObject);
    procedure TimerTimeTimer(Sender: TObject);
    procedure ButtonNewClick(Sender: TObject);
    procedure ButtonAboutClick(Sender: TObject);
    procedure ButtonOptionClick(Sender: TObject);
    procedure ButtonCloseMouseEnter(Sender: TObject);
    procedure ButtonCloseMouseExit(Sender: TObject);
    procedure ButtonHelpClick(Sender: TObject);
    procedure DrawGridPolyMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  private
   procedure WMNCHitTest(var M: TWMNCHitTest); message wm_NCHitTest;
  end;
  TSArray = array[1..4, 1..4] of Byte;                                          //Шаблон массива - поля
  TBitmaps = class                                                              //Текстуры
   public
    Back:TBitmap;
    Empty:TBitmap;
    BackGround:TBitmap;
    Win:TPNGObject;
    Right:TPNGObject;
    Down:TPNGObject;
    Up:TPNGObject;
    Left:TPNGObject;
    constructor Create;
  end;
  TStatistics = record
   Win:Integer;
   Lose:Integer;
   FirstBoom:Integer;
   MinTime:Integer;
   MaxTime:Integer;
   LastTime:Integer;
   Clicks:Integer;
   MinClicks:Integer;
   Bonus:Integer;
   MaxBonus:Integer;
  end;
  TGame = class
   Time:Cardinal;
   Wins:Word;
   procedure New;
   procedure Clear;
   function MayMoved(x,y:Byte):Byte;
   function Check:Boolean;
  end;


const
  Empty = 0;
  NLeft = 4;
  NUp = 8;
  NRight = 6;
  NDown = 2;
  NotMove = 5;

var
  FormMain: TFormMain;
  Game:TGame;
  SArray:TSArray;   //Значения
  Bitmaps:TBitmaps; //Текстуры
  Need:Boolean;     //Перетаскивание возможно
  Path:String;      //Рабочий каталог
  MouseOn:TPoint;
  LastPos:TPoint;

function LoadSkinFromDll(DllName:string):Boolean;  


implementation

{$R *.dfm}
 uses UResult, About, Settings;

function TGame.Check:Boolean;
var i,j, Num:Byte;
begin
 Result:=False;
 Num:=0;
 for i:=1 to 4 do
  for j:=1 to 4 do
   begin
    Inc(Num);
    if Num=16 then
     begin
      Result:=True;
      Exit;
     end;
    if SArray[j,i]<>Num then Exit;
   end;
 Result:=True;
end;

function TGame.MayMoved(x,y:Byte):Byte;
begin
 Result:=NotMove;
 if (SArray[x, y-1]=Empty) and (y-1>0) then
  begin
   Result:=NUp;
   Exit;
  end;
 if (SArray[x+1, y]=Empty) and (x+1<5) then
  begin
   Result:=NRight;
   Exit;
  end;
 if (SArray[x, y+1]=Empty) and (y+1<5) then
  begin
   Result:=NDown;
   Exit;
  end;
 if (SArray[x-1, y]=Empty) and (x-1>0) then
  begin
   Result:=NLeft;
   Exit;
  end;
end;

procedure TGame.Clear;
var i,j:Byte;
begin
 for i:=1 to 4 do
  for j:=1 to 4 do
   begin
    SArray[i,j]:=Empty;
   end;
end;

procedure TGame.New;
var i,j, Rnd:Byte;
 Use, UnUse:set of Byte;
begin
 Clear;
 Use:=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16];
 UnUse:=[];
 for i:=1 to 4 do
  for j:=1 to 4 do
   begin
    repeat
     Rnd:=Random(16)+1;
    until (not (Rnd in UnUse)) and (Rnd in Use);
    Include(UnUse, Rnd);
    if Rnd=16 then Continue;
    SArray[i,j]:=Rnd;
   end;
 Time:=0;
 FormMain.TimerTime.Enabled:=True;  
 FormMain.DrawGridPoly.Repaint;
end;

function LoadSkinFromDll(DllName:string):Boolean;
var DLL:Cardinal;
 S: array [0..255] of Char;
 Clr:string;
 Color:TColor;
 PNG:TPNGObject;
begin
 Dll:=LoadLibrary(PChar(Dllname));
 if DLL=0 then
  begin
   Result:=False;
   Exit;
  end;
 LoadString(DLL, 60000, S, 255);
 Clr:=StrPas(S);
 try
  Color:=StringToColor(Clr);
 except
  Color:=clWhite;
 end;
 FormMain.LabelFCount.Font.Color:=Color;
 FormMain.LabelTime.Font.Color:=Color;
 with Bitmaps do
  try
   Back.LoadFromResourceName(DLL, 'back');
   Left.LoadFromResourceName(DLL, 'left');
   Right.LoadFromResourceName(DLL, 'right');
   Down.LoadFromResourceName(DLL, 'down');
   Up.LoadFromResourceName(DLL, 'Up');
   Empty.LoadFromResourceName(DLL, 'Empty');
   BackGround.LoadFromResourceName(DLL, 'bg');
   Win.LoadFromResourceName(DLL, 'win');
   with FormMain do
    begin
     ImageBG.Picture.Bitmap:=Bitmaps.BackGround;
     ButtonClose.ImageNormal.LoadFromResourceName(DLL, 'close');
     ButtonHide.ImageNormal.LoadFromResourceName(DLL, 'hide');
     ButtonNew.ImageNormal.LoadFromResourceName(DLL, 'new');
     ButtonHelp.ImageNormal.LoadFromResourceName(DLL, 'help');
     ButtonAbout.ImageNormal.LoadFromResourceName(DLL, 'about');
     ButtonOption.ImageNormal.LoadFromResourceName(DLL, 'set');
     PNG:=TPNGObject.Create;
     PNG.LoadFromResourceName(DLL, 'time');
     ImageTime.Picture.Graphic:=PNG;
     PNG.LoadFromResourceName(DLL, 'bomb');
     ImageBombLeft.Picture.Graphic:=PNG;
     PNG.Free;
     DrawGridPoly.Repaint;
    end;
   FreeLibrary(DLL);
  except
   begin
    MessageBox(FormMain.Handle, 'Отсутствуют необходимые текстуры!'+#13+#10+'Программа будет закрыта.', '', MB_ICONSTOP or MB_OK);
    FreeLibrary(Dll);
    Application.Terminate;
   end;
  end;
 Result:=True;
end;

procedure TFormMain.WMNCHitTest (var M:TWMNCHitTest);
begin
 inherited;
 if (M.Result = htClient) and Need then M.Result := htCaption;
end;

constructor TBitmaps.Create;
begin
 Back:=TBitmap.Create;
 Left:=TPNGObject.Create;
 Right:=TPNGObject.Create;
 Down:=TPNGObject.Create;
 Up:=TPNGObject.Create;
 Empty:=TBitmap.Create;
 BackGround:=TBitmap.Create;
 Left:=TPNGObject.Create;
 Win:=TPNGObject.Create;
 inherited;
end;

procedure TFormMain.DrawGridPolyDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var Cell, W, H:Byte;
begin
 Cell:=SArray[ACol+1, ARow+1];
 case Cell of
  Empty:DrawGridPoly.Canvas.StretchDraw(Rect, Bitmaps.Empty);
 else
  DrawGridPoly.Canvas.Brush.Style:=bsClear;
  DrawGridPoly.Canvas.Font.Name:='Segoe UI';
  DrawGridPoly.Canvas.Font.Size:=25;
  DrawGridPoly.Canvas.Font.Style:=[fsBold];
  DrawGridPoly.Canvas.StretchDraw(Rect, Bitmaps.Back);
  W:=DrawGridPoly.Canvas.TextWidth(IntToStr(Cell));
  H:=DrawGridPoly.Canvas.TextHeight(IntToStr(Cell));
  DrawGridPoly.Canvas.TextOut(Rect.Left-(((Rect.Left-Rect.Right) div 2)+(W div 2)), Rect.Top-(((Rect.Top-Rect.Bottom) div 2)+(H div 2)), IntToStr(Cell));
 end;
 if (ACol=MouseOn.X) and (ARow=MouseOn.Y) and (Cell<>Empty) then
  begin
   case Game.MayMoved(ACol+1, ARow+1) of
    NUp:DrawGridPoly.Canvas.StretchDraw(Rect, Bitmaps.Up);
    NDown:DrawGridPoly.Canvas.StretchDraw(Rect, Bitmaps.Down);
    NLeft:DrawGridPoly.Canvas.StretchDraw(Rect, Bitmaps.Left);
    NRight:DrawGridPoly.Canvas.StretchDraw(Rect, Bitmaps.Right);
   else
    Exit;
   end;
  end;
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
 Need:=True;
 Game:=TGame.Create;
 Bitmaps:=TBitmaps.Create;
 Game.New;
 LoadSkinFromDll(Path+'Graphics\default.dll');
end;

procedure TFormMain.DrawGridPolyMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var C, R:Integer;
begin
 DrawGridPoly.MouseToCell(X, Y, C, R);
 Inc(C);
 Inc(R);
 case Game.MayMoved(C, R) of
  NotMove:Exit;
  NUp:
   begin
    SArray[C, R-1]:=SArray[C, R];
    SArray[C, R]:=Empty;
   end;
  NDown:
   begin
    SArray[C, R+1]:=SArray[C, R];
    SArray[C, R]:=Empty;
   end;
  NLeft:
   begin
    SArray[C-1, R]:=SArray[C, R];
    SArray[C, R]:=Empty;
   end;
  NRight:
   begin
    SArray[C+1, R]:=SArray[C, R];
    SArray[C, R]:=Empty;
   end;
 end;
 DrawGridPoly.Repaint;
 if Game.Check then
  begin
   TimerTime.Enabled:=False;
   Inc(Game.Wins);
   case FormResult.ShowModal of
    mrCancel:Application.Terminate;
    mrOk:Game.New;
   end;
   LabelFCount.Caption:=IntToStr(Game.Wins);
  end;
end;

procedure TFormMain.DrawGridPolyMouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
 Handled:=True;
end;

procedure TFormMain.DrawGridPolyMouseWheelUp(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
 Handled:=True;
end;

procedure TFormMain.ButtonCloseClick(Sender: TObject);
begin
 Application.Terminate;
end;

procedure TFormMain.ImageBGMouseEnter(Sender: TObject);
begin
 Need:=True;
end;

procedure TFormMain.ImageBGMouseLeave(Sender: TObject);
begin
 Need:=False;
end;

procedure TFormMain.ButtonHideClick(Sender: TObject);
begin
 Application.Minimize;
end;

procedure TFormMain.TimerTimeTimer(Sender: TObject);
begin
 Inc(Game.Time);
 LabelTime.Caption:=IntToStr(Game.Time);
end;

procedure TFormMain.ButtonNewClick(Sender: TObject);
begin
 if MessageBox(Handle, 'Вы уверены, что хотите начать новую игру?', '', MB_ICONWARNING or MB_YESNOCANCEL)=ID_YES
 then Game.New;
end;

procedure TFormMain.ButtonAboutClick(Sender: TObject);
begin
 FormHelp.ShowModal;
end;

procedure TFormMain.ButtonOptionClick(Sender: TObject);
begin
 FormSet.ShowModal;
end;

procedure TFormMain.ButtonCloseMouseEnter(Sender: TObject);
begin
 Need:=False;
end;

procedure TFormMain.ButtonCloseMouseExit(Sender: TObject);
begin
 Need:=True;
end;

procedure TFormMain.ButtonHelpClick(Sender: TObject);
var i,j,Num:Byte;
begin
 Game.Clear;
 Num:=0;
 for i:=1 to 4 do
  for j:=1 to 4 do
   begin
    Inc(Num);
    if Num=16 then Exit;
    SArray[j,i]:=Num;
   end;
 DrawGridPoly.Repaint;  
end;

procedure TFormMain.DrawGridPolyMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var ACol, ARow:Integer;
 GRect:TGridRect;
begin
 DrawGridPoly.MouseToCell(X, Y, ACol, ARow);
 GRect.Left:=ACol;
 GRect.Top:=ARow;
 DrawGridPoly.Selection:=GRect;
 MouseOn.X:=ACol;
 MouseOn.Y:=ARow;
 if LastPos.X<>MouseOn.X then
  begin
   LastPos:=MouseOn;
   DrawGridPoly.Repaint
  end
 else if LastPos.Y<>MouseOn.Y then
  begin
   LastPos:=MouseOn;
   DrawGridPoly.Repaint
  end; 
end;

initialization
   Path:=ExtractFilePath(ParamStr(0));

end.
