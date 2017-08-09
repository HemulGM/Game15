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
   //ListBoxStatistics.Items.Add('��� ����: '+IntToStr(Statistics.Bonus));
   ListBoxStatistics.Items.Add('����� ����: '+IntToStr(Stat[AScatter].LastTime)+' ���.');
   ListBoxStatistics.Items.Add('���-�� �����: '+IntToStr(Stat[AScatter].Clicks));
   ListBoxStatistics.Items.Add('');
   ListBoxStatistics.Items.Add('����� ����������');
   ListBoxStatistics.Items.Add('����������� �����: '+IntToStr(Stat[AScatter].MinTime)+' ���.');
   ListBoxStatistics.Items.Add('������������ �����: '+IntToStr(Stat[AScatter].MaxTime)+' ���.');
   ListBoxStatistics.Items.Add('�����: '+IntToStr(Stat[AScatter].Win));
   ListBoxStatistics.Items.Add('����������: '+IntToStr(Stat[AScatter].Lose));
   ListBoxStatistics.Items.Add('����������� ���-�� �����: '+IntToStr(Stat[AScatter].MinClicks));
   ListBoxStatistics.Items.EndUpdate;
  end;
end;

procedure TFormResult.FormShow(Sender: TObject);
begin
 ImageWin.Picture.Graphic:=Game.Bitmaps.Win;
 TrackBarDif.Position:=Game.ScatterNum;
 LabelCTime.Caption:=IntToStr(Game.Stat[Game.ScatterNum].LastTime)+' ���. ���-�� �����: '+IntToStr(Game.Stat[Game.ScatterNum].Clicks);
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
