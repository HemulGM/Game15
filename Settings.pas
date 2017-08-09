unit Settings;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls;

type
  TFormSet = class(TForm)
    ButtonClose: TButton;
    LabelDif: TLabel;
    TrackBarDif: TTrackBar;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    CheckBoxMix: TCheckBox;
    Bevel1: TBevel;
    LabelDifV: TLabel;
    ComboBoxGType: TComboBox;
    LabelGameType: TLabel;
    procedure ButtonCloseClick(Sender: TObject);
    procedure TrackBarDifChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CheckBoxMixClick(Sender: TObject);
    procedure ComboBoxGTypeChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormSet: TFormSet;
  Showed:Boolean;

implementation

{$R *.dfm}
 uses Main;

procedure TFormSet.ButtonCloseClick(Sender: TObject);
begin
 if TrackBarDif.Position <> ((Game.Scatter - 10) div 50) then
  if MessageBox(0, 'Ќачать игру с новым уровнем сложности?', '', MB_ICONINFORMATION or MB_YESNO) = ID_YES then
   begin
    Game.Scatter:=(TrackBarDif.Position*50)+10;
    Game.New(True);
   end;
 Close;
end;

procedure TFormSet.TrackBarDifChange(Sender: TObject);
begin
 LabelDifV.Caption:=IntToStr((TrackBarDif.Position*50)+10)+', сейчас: '+IntToStr(Game.Scatter);
end;

procedure TFormSet.FormShow(Sender: TObject);
begin
 TrackBarDif.Position:=((Game.Scatter - 10) div 50);
 //CheckBoxMix.Checked:=Game.ShowScatter;
 ComboBoxGType.ItemIndex:=Ord(Game.GameType);
end;

procedure TFormSet.CheckBoxMixClick(Sender: TObject);
begin
 //Game.ShowScatter:=CheckBoxMix.Checked;
end;

procedure TFormSet.ComboBoxGTypeChange(Sender: TObject);
begin
 Game.GameType:=TGameType(ComboBoxGType.ItemIndex);
end;

end.
