unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, XPMan, ExtCtrls, pngextra, pngimage, Buttons,
  PanelExt, DXClass, ComCtrls;

type
  TFormMain = class(TForm)
    ButtonClose: TPNGButton;
    LabelFCount: TLabel;
    ButtonHide: TPNGButton;
    LabelTime: TLabel;
    ImageTime: TImage;
    ImageWins: TImage;
    ButtonNew: TPNGButton;
    ButtonAbout: TPNGButton;
    ButtonOption: TPNGButton;
    XPManifest: TXPManifest;
    TimerTime: TTimer;
    DrawPanel: TDrawPanel;
    TimerPaint: TTimer;
    TimerMove: TDXTimer;
    ProgressBarPercent: TProgressBar;
    PNGButtonShowPic: TPNGButton;
    procedure FormCreate(Sender: TObject);
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
    procedure FormPaint(Sender: TObject);
    procedure TimerPaintTimer(Sender: TObject);
    procedure DrawPanelPaint(Sender: TObject);
    procedure DrawPanelMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure DrawPanelMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TimerMoveTimer(Sender: TObject; LagCount: Integer);
    procedure DrawPanelMouseLeave(Sender: TObject);
    procedure DrawPanelKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure PNGButtonShowPicMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure PNGButtonShowPicMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ProgressBarPercentMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer);
  private
   procedure WMNCHitTest(var M: TWMNCHitTest); message wm_NCHitTest;
  end;
  TSArray = array[1..4, 1..4] of Byte;                                          //Шаблон массива - поля
  TBitmaps = class                                                              //Текстуры
   public
    Pic:TBitmap;
    Pics:array[1..16] of TBitmap;
    Back:TBitmap;
    Empty:TBitmap;
    Fill:TBitmap;
    BackGround:TBitmap;
    Win:TPNGObject;
    Right:TPNGObject;
    Down:TPNGObject;
    Up:TPNGObject;
    Left:TPNGObject;
    function LoadSkinFromDll(DllName:string):Boolean;
    constructor Create(DllName:string);
  end;
  TStatistics = record
   Win:Integer;
   Lose:Integer;
   MinTime:Integer;
   MaxTime:Integer;
   LastTime:Integer;
   Clicks:Integer;
   MinClicks:Integer;
  end;
  TMovingRect = class
   New_C, New_R:Byte;
   Old_C, Old_R:Byte;
   Old_X, Old_Y:Word;
   New_X, New_Y:Word;
   Moving:Boolean;
   Numb:Byte;
   constructor Create;
  end;
  TGameType = (gtNums, gtPic);
  TGame = class
   private
    FIsPlaying:Boolean;
    FPercent:Byte;
    MouseOn:TPoint;
    LastPos:TPoint;
    procedure SetPercent(Value:Byte);
   public
    GameType:TGameType;
    SArray:TSArray;
    Bitmaps:TBitmaps;
    MovingRect:TMovingRect;
    Scatter:word;
    //ShowScatter:Boolean;
    Stat:array[0..9] of TStatistics;
    function ScatterNum:Byte;
    procedure New(SS:Boolean);
    procedure Clear;
    function MayMoved(x,y:Byte):Byte;
    function Check:Boolean;
    function Lead(C, R:Byte):Byte;
    procedure SaveResult;
    constructor Create;
    destructor Destroy;
   published
    property Percent:Byte read FPercent write SetPercent default 0;
  end;


const
  Empty   = 0;
  NLeft   = 4;
  NUp     = 8;
  NRight  = 6;
  NDown   = 2;
  NotMove = 5;
  BitWid  = 61;

var
  FormMain: TFormMain;
  DrawBMP:TBitmap;
  Game:TGame;
  Default:TSArray = (( 1, 5,  9, 13),
                     ( 2, 6, 10, 14),
                     ( 3, 7, 11, 15),
                     ( 4, 8, 12,  0));
                      //Значения
  Need:Boolean = True;//Перетаскивание окна
  Path:String;        //Рабочий каталог
  ShowPic:Boolean;
  procedure ActionCheck;


implementation

{$R *.dfm}
 uses UResult, About, Settings;


destructor TGame.Destroy;
begin
 SaveResult;
 inherited;
end;

procedure TGame.SaveResult;
var DataFile:file of TStatistics;
    i:Byte;
begin
 try
  AssignFile(DataFile, Path+'Results.dat');
  Rewrite(DataFile);
  for i:=0 to 9 do write(DataFile, Game.Stat[i]);
 finally
  CloseFile(DataFile);
 end;
end;

procedure TGame.SetPercent(Value:Byte);
begin
 FPercent:=Value;
 FormMain.ProgressBarPercent.Position:=Value;
end;

function TGame.ScatterNum:Byte;
begin
 Result:=(Scatter - 10) div 50;
end;

procedure ActionCheck;
begin
 with FormMain do
  begin
   if Game.Check then
    begin
     TimerTime.Enabled:=False;
     if Game.Stat[Game.ScatterNum].MinTime <=0 then Game.Stat[Game.ScatterNum].MinTime:=Game.Stat[Game.ScatterNum].LastTime;
     Game.Stat[Game.ScatterNum].MinTime:=Min(Game.Stat[Game.ScatterNum].MinTime, Game.Stat[Game.ScatterNum].LastTime);
     Game.Stat[Game.ScatterNum].MaxTime:=Max(Game.Stat[Game.ScatterNum].MaxTime, Game.Stat[Game.ScatterNum].LastTime);
     if Game.Stat[Game.ScatterNum].MinClicks <=0 then Game.Stat[Game.ScatterNum].MinClicks:=Game.Stat[Game.ScatterNum].Clicks;
     Game.Stat[Game.ScatterNum].MinClicks:=Min(Game.Stat[Game.ScatterNum].MinClicks, Game.Stat[Game.ScatterNum].Clicks);
     Inc(Game.Stat[Game.ScatterNum].Win);
     case FormResult.ShowModal of
      mrCancel:FormMain.Close;
      mrOk:
       begin
        if FormResult.TrackBarDif.Position <> Game.ScatterNum then
         begin
          if MessageBox(Application.Handle, 'Начать игру с новой сложностью?', '', MB_ICONINFORMATION or MB_YESNO) = ID_YES then Game.Scatter:=(FormResult.TrackBarDif.Position*50)+10; 
         end;
        Game.New(True);
       end;
     end;
    end;
   LabelFCount.Caption:=IntToStr(Game.Stat[Game.ScatterNum].Win);
  end;
end;

constructor TMovingRect.Create;
begin
 inherited;
 Moving:=False;
 Old_C:=1;
 Old_R:=1;
 Old_X:=0;
 Old_Y:=0;

 New_C:=1;
 New_R:=1;
 New_X:=0;
 New_Y:=0;
end;

constructor TGame.Create;
var i:Byte;
    Loaded:Boolean;
    DataFile:file of TStatistics;
begin
 inherited;
 Loaded:=False;
 if FileExists(Path+'Results.dat') then
  begin
   try
    AssignFile(DataFile, Path+'Results.dat');
    Reset(DataFile);
    for i:=0 to 9 do read(DataFile, Stat[i]);
    Loaded:=True;
   except
    Loaded:=False;
   end;
   CloseFile(DataFile);
  end;
 for i:=0 to 9 do
  begin
   if Loaded then Break;
   Stat[i].Win:=0;
   Stat[i].Lose:=0;
   Stat[i].MinTime:=-1;
   Stat[i].MaxTime:=-1;
   Stat[i].LastTime:=0;
   Stat[i].Clicks:=0;
   Stat[i].MinClicks:=0;
  end;
 Bitmaps:=TBitmaps.Create(Path+'Graphics\default.dll');
 MovingRect:=TMovingRect.Create;
 Scatter:=10;
end;

function TGame.Lead(C, R:Byte):Byte;
begin
 Result:=MayMoved(C, R);
 MovingRect.Numb:=SArray[C, R];
 MovingRect.Old_C:=C;
 MovingRect.Old_R:=R;
 MovingRect.Old_X:=(C-1)*BitWid;
 MovingRect.Old_Y:=(R-1)*BitWid;
 case Result of
  NotMove:Exit;
  NUp:
   begin
    SArray[C, R-1]:=SArray[C, R];
    MovingRect.New_C:=C;
    MovingRect.New_R:=R-1;
    SArray[C, R]:=Empty;
   end;
  NDown:
   begin
    SArray[C, R+1]:=SArray[C, R];
    MovingRect.New_C:=C;
    MovingRect.New_R:=R+1;
    SArray[C, R]:=Empty;
   end;
  NLeft:
   begin
    SArray[C-1, R]:=SArray[C, R];
    MovingRect.New_R:=R;
    MovingRect.New_C:=C-1;
    SArray[C, R]:=Empty;
   end;
  NRight:
   begin
    SArray[C+1, R]:=SArray[C, R];
    MovingRect.New_R:=R;
    MovingRect.New_C:=C+1;
    SArray[C, R]:=Empty;
   end;
 end;
 if FIsPlaying then Inc(Stat[ScatterNum].Clicks);
 MovingRect.New_X:=(MovingRect.New_C-1)*BitWid;
 MovingRect.New_Y:=(MovingRect.New_R-1)*BitWid;
 MovingRect.Moving:=True;
end;

function TGame.Check:Boolean;
var i, j, Num:Byte;
begin
 Result:=False;
 Num:=0;
 for i:=1 to 4 do
  for j:=1 to 4 do
   begin
    Inc(Num);
    if Num >= 16 then
     begin
      Result:=True;
      SArray[4, 4]:=16;
      Percent:=100;
      Exit;
     end;
    if SArray[j, i] <> Num then
     begin
      Percent:=Round((100 / 15)*(Num-1));
      Exit;
     end;
   end;
 Result:=True;
end;

function TGame.MayMoved(x, y:Byte):Byte;
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
begin
 SArray:=Default;
 FIsPlaying:=False;
end;

procedure TGame.New(SS:Boolean);
var i, j:Byte;
 CurValue:word;
begin
 FormMain.TimerTime.Enabled:=False;
 if FIsPlaying then Inc(Stat[ScatterNum].Lose);
 FIsPlaying:=False;
 Stat[ScatterNum].LastTime:=0;
 Stat[ScatterNum].Clicks:=0;
 Randomize;
 repeat
  Clear;
  CurValue:=0;
  while CurValue < Scatter do
   begin
    Inc(CurValue);
    repeat
     i:=Random(4)+1;
     j:=Random(4)+1;
    until (Lead(i, j) <> NotMove);
    {if ShowScatter and SS then
     begin
      Sleep(50);
      Application.ProcessMessages;
     end;    }
    if Application.Terminated then Exit;
   end;
 until not Check;
 Application.ProcessMessages;
 FIsPlaying:=True;
 Stat[ScatterNum].LastTime:=0;
 FormMain.TimerTime.Enabled:=True;
end;

function TBitmaps.LoadSkinFromDll(DllName:string):Boolean;
var DLL:Cardinal;
 S: array [0..255] of Char;
 Color:TColor;
 PNG:TPNGObject;
begin
 Result:=False;
 Dll:=LoadLibrary(PChar(Dllname));
 if DLL=0 then Exit;
 LoadString(DLL, 60000, S, 255);
 try
  Color:=StringToColor(StrPas(S));
 except
  Color:=clBlack;
 end;
 FormMain.LabelFCount.Font.Color:=Color;
 FormMain.LabelTime.Font.Color:=Color;
 try
  Back.LoadFromResourceName(DLL, 'back');
  Left.LoadFromResourceName(DLL, 'left');
  Right.LoadFromResourceName(DLL, 'right');
  Down.LoadFromResourceName(DLL, 'down');
  Up.LoadFromResourceName(DLL, 'up');
  Fill.Width:=BitWid;
  Fill.Height:=BitWid;
  Empty.LoadFromResourceName(DLL, 'empty');
  BackGround.LoadFromResourceName(DLL, 'bg');
  Win.LoadFromResourceName(DLL, 'win');
  with FormMain do
   begin
    Brush.Bitmap:=BackGround;
    ButtonClose.ImageNormal.LoadFromResourceName(DLL, 'close');
    ButtonHide.ImageNormal.LoadFromResourceName(DLL, 'hide');
    ButtonNew.ImageNormal.LoadFromResourceName(DLL, 'new');
    ButtonAbout.ImageNormal.LoadFromResourceName(DLL, 'about');
    ButtonOption.ImageNormal.LoadFromResourceName(DLL, 'set');
    PNG:=TPNGObject.Create;
    PNG.LoadFromResourceName(DLL, 'time');
    ImageTime.Picture.Graphic:=PNG;
    PNG.LoadFromResourceName(DLL, 'bomb');
    ImageWins.Picture.Graphic:=PNG;
    PNG.Free;
   end;
  FreeLibrary(DLL);
 except
  begin
   MessageBox(FormMain.Handle, 'Отсутствуют необходимые текстуры!', '', MB_ICONSTOP or MB_OK);
   FreeLibrary(Dll);
   Exit;
  end;
 end;
 Result:=True;
end;

procedure TFormMain.WMNCHitTest (var M:TWMNCHitTest);
begin
 inherited;
 if (M.Result = htClient) and Need then M.Result := htCaption;
end;

constructor TBitmaps.Create(DllName:string);
var i, X, Y:Byte;
begin
 inherited Create;
 Pic:=TBitmap.Create;
 Pic.LoadFromFile(Path+'Graphics\pic1.bmp');
 for i:=1 to 16 do
  begin
   Pics[i]:=TBitmap.Create;
   Pics[i].Width:=BitWid;
   Pics[i].Height:=BitWid;
   X:=BitWid*(((i - 1) mod 4));
   Y:=BitWid*(((i - 1) div 4));
   Pics[i].Canvas.CopyRect(Pics[i].Canvas.ClipRect, Pic.Canvas, Rect(X, Y, X+BitWid, Y+BitWid));
  end;
 Back:=TBitmap.Create;
 Left:=TPNGObject.Create;
 Right:=TPNGObject.Create;
 Down:=TPNGObject.Create;
 Up:=TPNGObject.Create;
 Empty:=TBitmap.Create;
 BackGround:=TBitmap.Create;
 Fill:=TBitmap.Create;
 Left:=TPNGObject.Create;
 Win:=TPNGObject.Create;
 LoadSkinFromDll(DllName);
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
 DrawBMP:=TBitmap.Create;
 DrawBMP.Width:=DrawPanel.Width;
 DrawBMP.Height:=DrawPanel.Height;
 DrawBMP.Canvas.Brush.Style:=bsClear;
 DrawBMP.Canvas.Font.Name:='Segoe UI';
 DrawBMP.Canvas.Font.Size:=25;
 DrawBMP.Canvas.Font.Style:=[fsBold];
 ClientHeight:=318;
 ClientWidth:=318;
 Game:=TGame.Create;
 Game.New(False);
end;

procedure TFormMain.ButtonCloseClick(Sender: TObject);
begin
 Close;
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
 if ShowPic then TimerTime.Interval:=700 else TimerTime.Interval:=1000;
 Inc(Game.Stat[Game.ScatterNum].LastTime);
 LabelTime.Caption:=IntToStr(Game.Stat[Game.ScatterNum].LastTime);
end;

procedure TFormMain.ButtonNewClick(Sender: TObject);
begin
 Game.New(True);
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

procedure TFormMain.FormPaint(Sender: TObject);
begin
 Canvas.Brush.Style:=bsClear;
 Canvas.Pen.Color:=clGray;
 Canvas.Rectangle(FormMain.ClientRect);
end;

procedure TFormMain.TimerPaintTimer(Sender: TObject);
begin
 DrawPanel.Repaint;
end;

procedure TFormMain.DrawPanelPaint(Sender: TObject);
var C, R:Byte;
    X, Y:Word;
var Cell:Byte;
    W, H:Byte;
begin
 with DrawBMP.Canvas, Game do
  begin
   if ShowPic and (GameType = gtPic) then Draw(0, 0, Bitmaps.Pic)
   else
    begin
     if MovingRect.Moving then
      case GameType of
       gtNums: Draw((MovingRect.Old_C-1)*BitWid, (MovingRect.Old_R-1)*BitWid, Bitmaps.Empty);
       gtPic: Draw((MovingRect.Old_C-1)*BitWid, (MovingRect.Old_R-1)*BitWid, Bitmaps.Fill);
      end;
     for C:=1 to 4 do
      for R:=1 to 4 do
       begin
        if (
            ((C = MovingRect.New_C) and (R = MovingRect.New_R)) or
            ((C = MovingRect.Old_C) and (R = MovingRect.Old_R))
           ) and (MovingRect.Moving)
        then Break;
        Cell:=SArray[C, R];
        Y:=(R-1)*BitWid;
        X:=(C-1)*BitWid;
        case Cell of
         Empty:
         case GameType of
          gtNums:Draw(X, Y, Bitmaps.Empty);
          gtPic:Draw(X, Y, Bitmaps.Fill);
         end;
        else
         case GameType of                                                       //Тип игры
          gtNums:                                                               //Цифры
           begin
            Draw(X, Y, Bitmaps.Back);
            W:=TextWidth(IntToStr(Cell));
            H:=TextHeight(IntToStr(Cell));
            TextOut(X+(61 div 2) - (W div 2), Y+(61 div 2) - (H div 2), IntToStr(Cell));
           end;
          gtPic:Draw(X, Y, Bitmaps.Pics[Cell]);                                 //Рисунок (мазайка)
         end;
        end;
        if (C-1 = MouseOn.X) and (R-1 = MouseOn.Y) and (Cell <> Empty) then
         begin
          case MayMoved(C, R) of
           NUp   :Draw(X, Y, Bitmaps.Up);
           NDown :Draw(X, Y, Bitmaps.Down);
           NLeft :Draw(X, Y, Bitmaps.Left);
           NRight:Draw(X, Y, Bitmaps.Right);
          end;
         end;
       end;
     if MovingRect.Moving then
      begin
       case GameType of
        gtNums:
         begin
          Draw(MovingRect.Old_X, MovingRect.Old_Y, Bitmaps.Back);
          W:=TextWidth(IntToStr(MovingRect.Numb));
          H:=TextHeight(IntToStr(MovingRect.Numb));
          TextOut(MovingRect.Old_X+(61 div 2) - (W div 2), MovingRect.Old_Y+(61 div 2) - (H div 2), IntToStr(MovingRect.Numb));
         end;
        gtPic:Draw(MovingRect.Old_X, MovingRect.Old_Y, Bitmaps.Pics[MovingRect.Numb]);
       end;
      end;
    end;
  end;
 DrawPanel.Canvas.Draw(0, 0, DrawBMP);
end;

procedure TFormMain.DrawPanelMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var ACol, ARow:Integer;
begin
 ACol:=Trunc(X / BitWid);
 ARow:=Trunc(Y / BitWid);
 with Game do
  begin
   MouseOn.X:=ACol;
   MouseOn.Y:=ARow;
   if  LastPos.X <> MouseOn.X then LastPos:=MouseOn
   else
    if LastPos.Y <> MouseOn.Y then LastPos:=MouseOn;
  end;
end;

procedure TFormMain.DrawPanelMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var C, R:Integer;
begin
 C:=Trunc(X / BitWid);
 R:=Trunc(Y / BitWid);
 Inc(C);
 Inc(R);
 Game.Lead(C, R);
 ActionCheck;
end;

procedure TFormMain.TimerMoveTimer(Sender: TObject; LagCount: Integer);
begin
 with Game do
  begin
   if MovingRect.Old_X < MovingRect.New_X then Inc(MovingRect.Old_X);

   if MovingRect.Old_X > MovingRect.New_X then Dec(MovingRect.Old_X);

   if MovingRect.Old_Y < MovingRect.New_Y then Inc(MovingRect.Old_Y);

   if MovingRect.Old_Y > MovingRect.New_Y then Dec(MovingRect.Old_Y);

   if (MovingRect.Old_Y = MovingRect.New_Y) and
      (MovingRect.Old_X = MovingRect.New_X)
   then MovingRect.Moving:=False;
  end;
end;

procedure TFormMain.DrawPanelMouseLeave(Sender: TObject);
begin
 Game.MouseOn:=Point(-1, -1);
end;

procedure TFormMain.DrawPanelKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var i, j, IDKey:Byte;
begin
 case Key of
  VK_DOWN:IDKey:=NDown;
  VK_UP:IDKey:=NUp;
  VK_RIGHT:IDKey:=NRight;
  VK_LEFT:IDKey:=NLeft;
 else Exit;
 end;
 for i:=1 to 4 do
  for j:=1 to 4 do
   begin
    if Game.MayMoved(i, j) = IDKey then
     begin
      Game.Lead(i, j);
      ActionCheck;
      Exit;
     end;
   end;
end;

procedure TFormMain.PNGButtonShowPicMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 ShowPic:=True;
end;

procedure TFormMain.PNGButtonShowPicMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 ShowPic:=False;
end;

procedure TFormMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 Game.SaveResult;
end;

procedure TFormMain.ProgressBarPercentMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
 ProgressBarPercent.Hint:=Format('Завершено %d%%', [ProgressBarPercent.Position]);
end;

initialization
   Path:=ExtractFilePath(ParamStr(0));

end.
