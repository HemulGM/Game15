unit UResult;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, pngimage, ExtCtrls, ComCtrls;

type
  TFormResult = class(TForm)
    ImageWin: TImage;
    ButtonNew: TButton;
    ButtonQuit: TButton;
    Bevel1: TBevel;
    LabelTime: TLabel;
    LabelCTime: TLabel;
    ButtonStatistics: TButton;
    ListBoxStatistics: TListBox;
    LabelDif: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    TrackBarDif: TTrackBar;
    LabelDifV: TLabel;
    procedure FormShow(Sender: TObject);
    procedure ButtonStatisticsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TrackBarDifChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormResult: TFormResult;
  Stat:Boolean;

implementation

{$R *.dfm}
 uses Main;

procedure SetStat(AScatter:Byte);
begin
 with FormResult, Game do
  begin
   ListBoxStatistics.Items.BeginUpdate;
   ListBoxStatistics.Clear;
   //ListBoxStatistics.Items.Add('Ваш счет: '+IntToStr(Statistics.Bonus));
   ListBoxStatistics.Items.Add('Время игры: '+IntToStr(Stat[AScatter].LastTime)+' сек.');
   ListBoxStatistics.Items.Add('Кол-во ходов: '+IntToStr(Stat[AScatter].Clicks));
   ListBoxStatistics.Items.Add('');
   ListBoxStatistics.Items.Add('Общая статистика');
   ListBoxStatistics.Items.Add('Минимальное время: '+IntToStr(Stat[AScatter].MinTime)+' сек.');
   ListBoxStatistics.Items.Add('Максимальное время: '+IntToStr(Stat[AScatter].MaxTime)+' сек.');
   ListBoxStatistics.Items.Add('Побед: '+IntToStr(Stat[AScatter].Win));
   ListBoxStatistics.Items.Add('Отмененных: '+IntToStr(Stat[AScatter].Lose));
   ListBoxStatistics.Items.Add('Минимальное кол-во ходов: '+IntToStr(Stat[AScatter].MinClicks));
   ListBoxStatistics.Items.EndUpdate;
  end;
end;

procedure TFormResult.FormShow(Sender: TObject);
begin
 ImageWin.Picture.Graphic:=Game.Bitmaps.Win;
 TrackBarDif.Position:=Game.ScatterNum;
 LabelCTime.Caption:=IntToStr(Game.Stat[Game.ScatterNum].LastTime)+' сек. Кол-во шагов: '+IntToStr(Game.Stat[Game.ScatterNum].Clicks);
 SetStat(TrackBarDif.Position);
end;

procedure TFormResult.ButtonStatisticsClick(Sender: TObject);
begin
 if Stat then ClientHeight:=160 else ClientHeight:=369;
 Stat:=not Stat;
end;

procedure TFormResult.FormCreate(Sender: TObject);
begin
 Stat:=False;
 ClientHeight:=160;
end;

procedure TFormResult.TrackBarDifChange(Sender: TObject);
begin
 SetStat(TrackBarDif.Position);
 LabelDifV.Caption:=IntToStr((TrackBarDif.Position * 50)+10);
end;

end.
