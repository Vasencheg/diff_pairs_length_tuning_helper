{..............................................................................}
{ Summary   Not filled yet                                                     }
{                                                                              }
{ Created by:    Vasilev Roman aka Vasencheg                                   }
{..............................................................................}

{..............................................................................}

Uses
  FileCtrl, Windows, Messages,
  SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, Menus, ComCtrls, Buttons, Grids, StdCtrls, Windows, Variants,
  LCLType;

const
   PROG_VERSION = '1.0';

var
   Board                    : IPCB_Board;
   ICDelayParsedFileSL      : TStringList;
   DiffPairsSL              : TStringList;
   NetsICDelaySL            : TStringList;
   IniFileName              : String;

   SelectedDiffPair         : IPCB_DifferentialPair;
   BoardSelectedDiffPair    : IPCB_DifferentialPair;
   CurrentReferenceDP       : IPCB_DifferentialPair;
   ReferenceICLengthF       : Double;
   ReferenceICDelayF        : Double;
   ReferenceBoardLengthF    : Double;
   ReferenceTotalLengthF    : Double;


function WriteStringToIniFile(key : String, field : String, fvalue : String) : Integer;
var
    IniFile    : TIniFile;
begin
    if IniFileName = '' then
    begin
        result := -1;
        exit;
    end;

    IniFile := TIniFile.Create(IniFileName);
    try
        with IniFile do
        begin
            WriteString(key, field, fvalue);
        end;
    finally
        IniFile.Free;
    end;

    result := 0;
end;


function ReadStringFromIniFile(key : String, field : String, defvalue : String) : String;
var
    IniFile    : TIniFile;
begin
    if IniFileName = '' then
    begin
        result := '';
        exit;
    end;
    IniFile := TIniFile.Create(IniFileName);
    try
        with IniFile do
        begin
            result := ReadString(key, field, '');
            if result = '' then
            begin
                WriteString(key, field, defvalue);
                result := defvalue;
            end;
        end;
    finally
        IniFile.Free;
    end;

end;


function GetCurrentDPClassName(dummy : Integer = 0) : String;
begin
    if ComboBoxNetClass.ItemIndex <> -1 then
        result := ComboBoxNetClass.Items[(ComboBoxNetClass.ItemIndex)]
    else
        result := '';
end;


function GetCurrentDPClass(dummy : Integer = 0) : IPCB_ObjectClass;
begin
    if ComboBoxNetClass.ItemIndex <> -1 then
        result := ComboBoxNetClass.Items.GetObject(ComboBoxNetClass.ItemIndex)
    else
        result := Nil;
end;


function GetDPClassIndex(DPClassName : String) :Integer;
begin
    result := ComboBoxNetClass.Items.IndexOf(DPClassName);
end;


function SetDPClass(DPClassName : String) : Integer;
var
    i: Integer;
begin
    result := -1;
    i := GetDPClassIndex(DPClassName);
    if i <> -1 then
    begin
        ComboBoxNetClass.SetItemIndex(i);
        CurrentReferenceDP := nil;
        result := i;
    end;
end;


procedure UpdateReferenceDPList(dummy : Integer = 0);
var
    DiffPair : IPCB_DifferentialPair;
    Name     : String;
    i        : Integer;
begin
    if DiffPairsSL.Count = 0 then exit;
    ComboBoxReferencePair.Clear;
    for i := 0 to DiffPairsSL.Count - 1 do
    begin
        DiffPair := DiffPairsSL.GetObject(i);
        Name     := DiffPair.Name;
        ComboBoxReferencePair.Items.AddObject(Name, DiffPair);
    end
end;


function GetReferenceDPName(dummy : Integer = 0) : String;
begin
    if ComboBoxReferencePair.ItemIndex <> -1 then
        result := ComboBoxReferencePair.Items[(ComboBoxReferencePair.ItemIndex)]
    else
        result := '';
end;


function GetReferenceDPIndex(ReferencePairName : String) :Integer;
begin
    result := ComboBoxReferencePair.Items.IndexOf(ReferencePairName);
end;


function GetReferenceDP(dummy : Integer = 0) : IPCB_DifferentialPair;
begin
    if ComboBoxReferencePair.ItemIndex <> -1 then
        result := ComboBoxReferencePair.Items.GetObject(ComboBoxReferencePair.ItemIndex)
    else
        result := Nil;
end;


procedure UpdateReferenceParams(dummy : Integer = 0);
var
    DiffPair : IPCB_DifferentialPair;
    ICPosLengthF, ICPosDelayF, PosBoardLengthF, PosTotalLengthF : Double;
    ICNegLengthF, ICNegDelayF, NegBoardLengthF, NegTotalLengthF : Double;
    DelayF  : Double;
    i, j    : Integer;
begin
    DiffPair := GetReferenceDP;
    if DiffPair <> Nil then
    begin
        DelayF := StrToFloat(Delay.Text);

        // Positive net
        j := NetsICDelaySL.IndexOfObject(DiffPair.PositiveNet);
        if CheckBoxICDelay.Checked and (j <> -1) then
            ICPosDelayF := StrToFloat(NetsICDelaySL.Get(j))
        else
            ICPosDelayF := 0;
        ICPosLengthF    := ICPosDelayF / DelayF;
        PosBoardLengthF := CoordToMMs_FullPrecision(DiffPair.PositiveNet.RoutedLength);
        PosTotalLengthF := ICPosLengthF + PosBoardLengthF;

        // Negative net
        j := NetsICDelaySL.IndexOfObject(DiffPair.NegativeNet);
        if CheckBoxICDelay.Checked and (j <> -1) then
            ICNegDelayF := StrToFloat(NetsICDelaySL.Get(j))
        else
            ICNegDelayF := 0;
        ICNegLengthF    := ICNegDelayF / DelayF;
        NegBoardLengthF := CoordToMMs_FullPrecision(DiffPair.NegativeNet.RoutedLength);
        NegTotalLengthF := ICNegLengthF + NegBoardLengthF;

        ReferenceICLengthF    := ( ICPosLengthF + ICNegLengthF ) / 2;
        ReferenceICDelayF     := ( ICPosDelayF + ICNegDelayF ) / 2;
        ReferenceBoardLengthF := ( PosBoardLengthF + NegBoardLengthF ) / 2;
        ReferenceTotalLengthF := ( PosTotalLengthF + NegTotalLengthF ) / 2;
    end
    else
    begin
        ReferenceICLengthF    := 0;
        ReferenceICDelayF     := 0;
        ReferenceBoardLengthF := 0;
        ReferenceTotalLengthF := 0;
    end;

end;


function SetReferenceDP(ReferencePairName : String) : Integer;
var
    i: Integer;
begin
    i := GetReferenceDPIndex(ReferencePairName);
    if i <> -1 then
    begin
        if Assigned(CurrentReferenceDP) then
            DiffPairsSL[DiffPairsSL.IndexOfObject(CurrentReferenceDP)] := CurrentReferenceDP.Name;

        ComboBoxReferencePair.SetItemIndex(i);
        CurrentReferenceDP := GetReferenceDP;

        DiffPairsSL[DiffPairsSL.IndexOfObject(CurrentReferenceDP)] := '= [  ' + CurrentReferenceDP.Name + '  ]';
        WriteStringToIniFile(GetCurrentDPClassName, 'ReferencePair', ReferencePairName);

    end;

    result := i;
    UpdateReferenceParams;
end;


function GetIC(dummy : Integer = 0) : IPCB_Component;
Begin
    if ComboBoxIC.ItemIndex = -1 then
        result := Nil
    else
        result := ComboBoxIC.Items.GetObject(ComboBoxIC.ItemIndex);
end;


function GetICName(dummy : Integer = 0) : String;
begin
    if ComboBoxIC.ItemIndex <> -1 then
        result := ComboBoxIC.Items[(ComboBoxIC.ItemIndex)]
    else
        result := '';
end;


function GetICIndex(ICName : String) : Integer;
begin
    result := ComboBoxIC.Items.IndexOf(ICName);
end;


function SetIC(ICName : String = '') : Integer;
var
    i: Integer;
begin
    i := GetICIndex(ICName);
    if i <> -1 then
    begin
        ButtonLoadFile.Enabled := True;
        WriteStringToIniFile(GetCurrentDPClassName, 'ICDesignator', ICName);
    end
    else
        ButtonLoadFile.Enabled := False;

    ComboBoxIC.SetItemIndex(i);
    result := i;
end;


function GetCurrentUnits(dummy : Integer = 0) : String;
begin
   if UnitsPS.Checked  then result := 'ps'
   else                     result := 'mm'
end;


procedure SetUnits(units : String = 'mm');
begin
    if units = 'ps' then
    begin
        D2DSkewTolerance.Text := FloatToStrF(StrToFloat(D2DSkewTolerance.Text) * StrToFloat(Delay.Text), ffFixed, 7, 3);
        P2NSkewTolerance.Text := FloatToStrF(StrToFloat(P2NSkewTolerance.Text) * StrToFloat(Delay.Text), ffFixed, 7, 3);
        UnitsPS.Checked := True;
    end
    else if units = 'mm' then
    begin
        D2DSkewTolerance.Text := FloatToStrF(StrToFloat(D2DSkewTolerance.Text) / StrToFloat(Delay.Text), ffFixed, 7, 3);
        P2NSkewTolerance.Text := FloatToStrF(StrToFloat(P2NSkewTolerance.Text) / StrToFloat(Delay.Text), ffFixed, 7, 3);
        UnitsMM.Checked := True;
    end
    else
        exit;

    WriteStringToIniFile(GetCurrentDPClassName, 'Units', units);
    WriteStringToIniFile(GetCurrentDPClassName, 'D2DSkewTolerance', D2DSkewTolerance.Text);
    WriteStringToIniFile(GetCurrentDPClassName, 'P2NSkewTolerance', P2NSkewTolerance.Text);
end;


function ParseICDelayFile(filename : String = 'No File Choosen') : TStringList;
var
    ParsedFileSL: TStringList;
begin
    result := Nil;
    ParsedFileSL := TStringList.Create;
    ParsedFileSL.NameValueSeparator := ';';

    LabelFileName.Caption := 'No File Choosen';
    if (filename <> 'No File Choosen') then
    begin
        if (ExtractFileExt(filename) = '.csv') then
        begin
            WriteStringToIniFile(GetCurrentDPClassName, 'ICDelaysFileName', filename);
            ParsedFileSL.LoadFromFile(filename);
            LabelFileName.Caption := ExtractFileName(filename);
            result := ParsedFileSL;
        end
    end;
end;


procedure UpdateDiffPairsInfo(dummy : Integer = 0);
var
    DiffPair            : IPCB_DifferentialPair;
    ICPosDelayF         : Double;
    ICNegDelayF         : Double;
    ICLengthF           : Double;
    ICPosLengthF        : Double;
    ICNegLengthF        : Double;
    NegLengthF          : Double;
    PosLengthF          : Double;
    PosBoardLengthF     : Double;
    NegBoardLengthF     : Double;
    PosTotalLengthF     : Double;
    NegTotalLengthF     : Double;
    BoardLengthF        : Double;
    TotalLengthF        : Double;
    EstimatedBoardLengthF  : Double;
    D2DSkewToleranceF   : Double;
    P2NSkewToleranceF   : Double;
    DelayF, d           : Double;
    i, j                : Integer;
    PhaseOutOfRange     : Boolean;
    PhaseOutOfRangeQty  : Integer;
    DelayOutOfRangeQty  : Integer;
begin
    PhaseOutOfRangeQty := 0;
    DelayOutOfRangeQty := 0;
    DiffPairInfo.RowCount := DiffPairsSL.Count + 1;
    DelayF := StrToFloat(Delay.Text);

    if D2DSkewTolerance.Text <> '' then D2DSkewToleranceF := StrToFloat(D2DSkewTolerance.Text)
    else                                D2DSkewToleranceF := 0;

    if P2NSkewTolerance.Text <> '' then P2NSkewToleranceF := StrToFloat(P2NSkewTolerance.Text)
    else                                P2NSkewToleranceF := 0;

    for i := 1 to DiffPairsSL.Count do
    begin
        DiffPair := DiffPairsSL.GetObject(i - 1);
        DiffPairInfo.Cells[0, i] := DiffPairsSL[i - 1];

        // Positive net
        j := NetsICDelaySL.IndexOfObject(DiffPair.PositiveNet);
        if CheckBoxICDelay.Checked and (j <> -1) then
            ICPosDelayF := StrToFloat(NetsICDelaySL.Get(j))
        else
            ICPosDelayF := 0;
        ICPosLengthF    := ICPosDelayF / DelayF;
        PosBoardLengthF := CoordToMMs_FullPrecision(DiffPair.PositiveNet.RoutedLength);
        PosTotalLengthF := ICPosLengthF + PosBoardLengthF;

        // Negative net
        j := NetsICDelaySL.IndexOfObject(DiffPair.NegativeNet);
        if CheckBoxICDelay.Checked and (j <> -1) then
            ICNegDelayF := StrToFloat(NetsICDelaySL.Get(j))
        else
            ICNegDelayF := 0;
        ICNegLengthF    := ICNegDelayF / DelayF;
        NegBoardLengthF := CoordToMMs_FullPrecision(DiffPair.NegativeNet.RoutedLength);
        NegTotalLengthF := ICNegLengthF + NegBoardLengthF;

        ICLengthF    := ( ICPosLengthF + ICNegLengthF ) / 2;
        BoardLengthF := ( PosBoardLengthF + NegBoardLengthF ) / 2;
        TotalLengthF := ICLengthF + BoardLengthF;

        if ReferenceTotalLengthF <> 0 then
            EstimatedBoardLengthF :=  ReferenceTotalLengthF - ICLengthF
        else
            EstimatedBoardLengthF := 0;

        if UnitsPS.Checked then d := DelayF
        else                    d := 1;

        DiffPairInfo.Cells[1, i] := FloatToStrF(ICLengthF * d, ffFixed, 7, 3);
        DiffPairInfo.Cells[2, i] := FloatToStrF(BoardLengthF * d, ffFixed, 7, 3);
        DiffPairInfo.Cells[3, i] := FloatToStrF(EstimatedBoardLengthF * d, ffFixed, 7, 3);
        DiffPairInfo.Cells[4, i] := FloatToStrF(TotalLengthF * d, ffFixed, 7, 3);

        if ( Abs(PosTotalLengthF - NegTotalLengthF) * d >  P2NSkewToleranceF) then
        begin
            PhaseOutOfRange := True;
            DiffPairInfo.Cells[6, i] := 'FAIL';
            Inc(PhaseOutOfRangeQty);
        end
        else
        begin
            PhaseOutOfRange := False;
            DiffPairInfo.Cells[6, i] := 'PASS';
        end;

        if ( Abs(ReferenceTotalLengthF - TotalLengthF) * d > D2DSkewToleranceF ) then
        begin
            DiffPairInfo.Cells[5, i] := 'FAIL';
            Inc(DelayOutOfRangeQty);
        end
        else
            DiffPairInfo.Cells[5, i] := 'PASS';

        if (DiffPair = SelectedDiffPair) then
        begin
            DiffPairNetsInfo.Cells[0, 1] := DiffPair.PositiveNet.Name;
            DiffPairNetsInfo.Cells[1, 1] := FloatToStrF(ICPosLengthF * d, ffFixed, 7, 3);
            DiffPairNetsInfo.Cells[2, 1] := FloatToStrF(PosBoardLengthF * d, ffFixed, 7, 3);
            DiffPairNetsInfo.Cells[3, 1] := FloatToStrF(PosTotalLengthF * d, ffFixed, 7, 3);

            DiffPairNetsInfo.Cells[0, 2] := DiffPair.NegativeNet.Name;
            DiffPairNetsInfo.Cells[1, 2] := FloatToStrF(ICNegLengthF * d, ffFixed, 7, 3);
            DiffPairNetsInfo.Cells[2, 2] := FloatToStrF(NegBoardLengthF * d, ffFixed, 7, 3);
            DiffPairNetsInfo.Cells[3, 2] := FloatToStrF(NegTotalLengthF * d, ffFixed, 7, 3);

            if (PhaseOutOfRange) then
            begin
                DiffPairNetsInfo.Cells[4, 1] := 'FAIL';
                DiffPairNetsInfo.Cells[4, 2] := 'FAIL';
            end
            else
            begin
                DiffPairNetsInfo.Cells[4, 1] := 'PASS';
                DiffPairNetsInfo.Cells[4, 2] := 'PASS';
            end
        end;
    end;

    if (DelayOutOfRangeQty <> 0) then
        D2DSkewTolerance.Color := clRed
    else
        D2DSkewTolerance.Color := clLime;

    if (PhaseOutOfRangeQty <> 0) then
        P2NSkewTolerance.Color := clRed
    else
        P2NSkewTolerance.Color := clLime;

end;


procedure GenerateDiffPairsInfoSL(dummy : Integer = 0);
var
    Iterator : IPCB_BoardIterator;
    DPClass  : IPCB_ObjectClass;
    Net      : IPCB_Net;
    DiffPair : IPCB_DifferentialPair;
    PadIter  : IPCB_GroupIterator;
    IC       : IPCB_Component;
    Pad      : IPCB_Pad2;
    DelayS   : String;
    IsAdded  : Boolean;
    IsFound  : Boolean;
begin
    DPClass := GetCurrentDPClass;
    if DPClass = Nil then exit;

    IC := GetIC;

    if DiffPairsSL <> nil then  DiffPairsSL := nil;
    DiffPairsSL := TStringList.Create;

    if NetsICDelaySL <> nil then  NetsICDelaySL := nil;
    NetsICDelaySL := TStringList.Create;

    UpdateInfoTimer.Enabled := False;

    Iterator := Board.BoardIterator_Create;
    Iterator.SetState_FilterAll;
    Iterator.AddFilter_ObjectSet(MkSet(eDifferentialPairObject));
    DiffPair := Iterator.FirstPCBObject;
    While (DiffPair <> nil) Do
    Begin
        If (DPClass.IsMember(DiffPair)) Then
        begin
            DiffPairsSL.AddObject(DiffPair.Name, DiffPair);
            IsAdded := False;

            if (IC <> nil) and CheckBoxICDelay.Checked then
            begin
                PadIter := IC.GroupIterator_Create;
                PadIter.SetState_FilterAll;
                PadIter.AddFilter_ObjectSet(MkSet(ePadObject));

                Pad := PadIter.FirstPCBObject;
                while (Pad <> nil) do
                begin
                    if Pad.InNet then
                    begin
                        IsFound := True;
                        if (Pad.Net.I_ObjectAddress = DiffPair.PositiveNet.I_ObjectAddress) then
                            Net := DiffPair.PositiveNet
                        else if (Pad.Net.I_ObjectAddress = DiffPair.NegativeNet.I_ObjectAddress) then
                            Net := DiffPair.NegativeNet
                        else
                            isFound := False;

                        if IsFound then
                        begin
                            // Now get delay
                            DelayS := Pad.Name;
                            DelayS := ICDelayParsedFileSL.Values[DelayS];

                            if DelayS <> '' then
                            begin
                                NetsICDelaySL.AddObject(DelayS, Net);
                                IsAdded := True;
                            end;
                        end;
                    end;
                    Pad := PadIter.NextPCBObject;
                end;
                IC.GroupIterator_Destroy(PadIter);
            end;

            if not IsAdded then NetsICDelaySL.AddObject('0',Net);
        end;
        DiffPair := Iterator.NextPCBObject;
    End;

    Board.BoardIterator_Destroy(Iterator);
    UpdateInfoTimer.Enabled := True;
end;


procedure CreateStringGridHeader ( dummy : Integer = 0 );
var
    UnitType : String;
begin
    if UnitsPS.Checked then UnitType := 'T'
    else                    UnitType := 'L';

    DiffPairInfo.Cells[0,0] :=  'Designator';
    DiffPairInfo.Cells[1,0] :=  UnitType + 'ic';
    DiffPairInfo.Cells[2,0] :=  UnitType + 'b';
    DiffPairInfo.Cells[3,0] :=  UnitType + 'eb';
    DiffPairInfo.Cells[4,0] :=  UnitType + 'sum';
    DiffPairInfo.Cells[5,0] :=  'D2D';
    DiffPairInfo.Cells[6,0] :=  'P2N';

    DiffPairNetsInfo.Cells[0,0] := 'Designator';
    DiffPairNetsInfo.Cells[1,0] := UnitType + 'ic';;
    DiffPairNetsInfo.Cells[2,0] := UnitType + 'b';
    DiffPairNetsInfo.Cells[3,0] := UnitType + 'sum';
    DiffPairNetsInfo.Cells[4,0] := 'P2N';
end;


procedure LoadDiffPairClassSettings(DiffPairClassName : String);
var
    ReferencePairName : String;
    ICDesignator      : String;
    ICDelaysFileName  : String;
    IncludeICDelay    : String;
    UsedUnits         : String;
    i                 : Integer;
begin
    SelectedDiffPair       := Nil;
    BoardSelectedDiffPair  := Nil;

    i := SetDPClass(DiffPairClassName);
    if  i <> -1 then
    begin
        ReferencePairName := ReadStringFromIniFile(DiffPairClassName, 'ReferencePair', '');

        ICDesignator := ReadStringFromIniFile(DiffPairClassName, 'ICDesignator', '');
        SetIC(ICDesignator);

        ICDelaysFileName := ReadStringFromIniFile(DiffPairClassName, 'ICDelaysFileName', 'No File Choosen');
        ICDelayParsedFileSL := ParseICDelayFile(ICDelaysFileName);

        UsedUnits := ReadStringFromIniFile(DiffPairClassName, 'Units', 'mm');
        if UsedUnits = 'ps' then UnitsPS.Checked := True
        else                     UnitsMM.Checked := True;

        Delay.Text := ReadStringFromIniFile(DiffPairClassName, 'Delay', '6.15');

        D2DSkewTolerance.Text := ReadStringFromIniFile(DiffPairClassName, 'D2DSkewTolerance', '0.127');

        P2NSkewTolerance.Text := ReadStringFromIniFile(DiffPairClassName, 'P2NSkewTolerance', '0.127');

        GenerateDiffPairsInfoSL;
        UpdateReferenceDPList;
        SetReferenceDP(ReferencePairName);

        IncludeICDelay := ReadStringFromIniFile(DiffPairClassName, 'IncludeICDelay', 'False');
        CheckBoxICDelay.SetChecked(StrToBool(IncludeICDelay));
    end;
end;


procedure Start;
var
    iterator : IPCB_BoardIterator;
    NetClass : IPCB_ObjectClass;
    comp     : IPCB_Component;
    DiffPairClassName : String;
begin
    Board := PCBServer.GetCurrentPCBBoard;
    if Board = nil then exit;

    Iterator := Board.BoardIterator_Create;
    Iterator.SetState_FilterAll;
    Iterator.AddFilter_ObjectSet(MkSet(eComponentObject));
    comp := Iterator.FirstPCBObject;
    While comp <> NIl Do
    Begin
        ComboBoxIC.Items.AddObject(comp.Name.Text, comp);

        comp := Iterator.NextPCBObject;
    End;
    Board.BoardIterator_Destroy(Iterator);

    Iterator := Board.BoardIterator_Create;
    Iterator.SetState_FilterAll;
    Iterator.AddFilter_ObjectSet(MkSet(eClassObject));
    NetClass := Iterator.FirstPCBObject;
    While NetClass <> NIl Do
    Begin
        If ((NetClass.MemberKind = eClassMemberKind_DifferentialPair) and (NetClass.Name <> 'All Nets')) Then
            ComboBoxNetClass.Items.AddObject(NetClass.Name, NetClass);

        NetClass := Iterator.NextPCBObject;
    End;
    Board.BoardIterator_Destroy(Iterator);

    IniFileName := ExtractFilePath(Board.FileName) + ExtractFileName(Board.FileName) + '.ini';

    DiffPairClassName := ReadStringFromIniFile('GENERAL', 'DiffPairClass', '');
    FormDPLengthTuning.FormStyle := StrToInt(ReadStringFromIniFile('GENERAL', 'FormStyle', '0'));
    if FormDPLengthTuning.FormStyle = fsStayOnTop then StayOnTop.SetChecked(true)
                                                  else  StayOnTop.SetChecked(false);

    LoadDiffPairClassSettings(DiffPairClassName);

    FormDPLengthTuning.Caption := FormDPLengthTuning.Caption + ' v ' + PROG_VERSION;
    FormDPLengthTuning.Show;
end;


procedure TFormDPLengthTuning.ButtonLoadFileClick(Sender: TObject);
var
    ParsedFileSL    : TStringList;
    FileName        : String;
begin
    if (OpenFileDialog.Execute) then FileName := OpenFileDialog.FileName;

    ParsedFileSL := ParseICDelayFile(FileName);
    if ParsedFileSL <> Nil then
    begin
       ICDelayParsedFileSL := ParsedFileSL;
       GenerateDiffPairsInfoSL;
    end;
end;


procedure TFormDPLengthTuning.ComboBoxICChange(Sender: TObject);
begin
    SetIC(GetICName);
end;


procedure TFormDPLengthTuning.DiffPairInfoSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
begin
    if (ARow <> 0) and (DiffPairsSL.Count > 0) then
        SelectedDiffPair := DiffPairsSL.GetObject(ARow - 1)
    else
        SelectedDiffPair := Nil;

    CanSelect := True;
end;


procedure TFormDPLengthTuning.FormDPLengthTuningCreate(Sender: TObject);
begin
    CreateStringGridHeader;
end;


procedure TFormDPLengthTuning.UpdateInfoTimer(Sender: TObject);
var
    BoardSelectedDPName     : String;
    LastBoardSelectedDPName : String;
    Prim                    : IPCB_Primitive;
    j, i                    : Integer;
    NName                   : String;
    CurrentNName            : String;
    NetsInfoRow             : Integer;
begin
    UpdateReferenceParams;
    UpdateDiffPairsInfo;

    for i := 0 to Board.SelectecObjectCount - 1 do
    begin
        Prim := Board.SelectecObject[i];
        if ((Prim.ObjectId <> eTrackObject) and (Prim.ObjectId <> ePadObject) and (Prim.ObjectId <> eViaObject)) then break;

        NetsInfoRow := 2;
        if Prim.InNet = False then continue;

        NName := Prim.Net.Name;
        if Pos('_P', NName) > 0 then
        begin
            BoardSelectedDPName := StringReplace(NName, '_P', '', rfReplaceAll);
            NetsInfoRow := 1;
        end
        else if Pos( '_N', NName) > 0 then
            BoardSelectedDPName := StringReplace(NName, '_N', '', rfReplaceAll)
        else
            BoardSelectedDPName := '';

        if BoardSelectedDiffPair <> Nil then LastBoardSelectedDPName := BoardSelectedDiffPair.Name;

        if ((BoardSelectedDPName <> LastBoardSelectedDPName) or (DiffPairNetsInfo.Row <> NetsInfoRow)) and (BoardSelectedDPName <> '') then
        begin
            j := DiffPairsSL.IndexOf(BoardSelectedDPName);
            if j <> -1 then
            begin
                BoardSelectedDiffPair := DiffPairsSL.GetObject(j);
                DiffPairInfo.Row      := j + 1;
                DiffPairNetsInfo.Row  := NetsInfoRow;
            end;
        end;

        // exit from cycle on first occurence
        if (BoardSelectedDPName <> '') then break;

    end;

end;


procedure TFormDPLengthTuning.ComboBoxNetClassChange(Sender: TObject);
begin
    if GetCurrentDPClass = Nil then exit;

    WriteStringToIniFile('GENERAL', 'DiffPairClass', GetCurrentDPClassName);
    LoadDiffPairClassSettings(GetCurrentDPClassName);
end;


procedure TFormDPLengthTuning.ComboBoxReferencePairChange(Sender: TObject);
begin
    SetReferenceDP(GetReferenceDPName);
end;


procedure TFormDPLengthTuning.CheckBoxICDelayClick(Sender: TObject);
begin
    if CheckBoxICDelay.Checked then
    begin
        if (LabelfileName.Caption = 'No File Choosen') then
        begin
            ShowMessage('You must choose file with length info inside IC');
            CheckBoxICDelay.Checked := False;
            exit;
        end;
    end;

    WriteStringToIniFile(GetCurrentDPClassName, 'IncludeICDelay', BoolToStr(CheckBoxICDelay.Checked, True));
    GenerateDiffPairsInfoSL;
    SetReferenceDP(GetReferenceDPName);
    UpdateReferenceParams;
end;


procedure TFormDPLengthTuning.UnitsClick(Sender: TObject);
begin
    SetUnits(GetCurrentUnits);
    CreateStringGridHeader;
end;


procedure TFormDPLengthTuning.D2DSkewToleranceChange(Sender: TObject);
begin
    D2DSkewTolerance.Text := StringReplace(D2DSkewTolerance.Text, ',', '.', rfReplaceAll);
    WriteStringToIniFile(GetCurrentDPClassName, 'D2DSkewTolerance', D2DSkewTolerance.Text);
end;


procedure TFormDPLengthTuning.DelayChange(Sender: TObject);
begin
    Delay.Text := StringReplace(Delay.Text, ',', '.', rfReplaceAll);
    WriteStringToIniFile(GetCurrentDPClassName, 'Delay', Delay.Text);
end;


procedure TFormDPLengthTuning.P2NSkewToleranceChange(Sender: TObject);
begin
    P2NSkewTolerance.Text := StringReplace(P2NSkewTolerance.Text, ',', '.', rfReplaceAll);
    WriteStringToIniFile(GetCurrentDPClassName, 'P2NSkewTolerance', P2NSkewTolerance.Text);
end;


procedure TFormDPLengthTuning.StayOnTopClick(Sender: TObject);
var
   style : Integer;
begin
    if StayOnTop.Checked then style := fsStayOnTop
                         else style := fsNormal;

    FormDPLengthTuning.FormStyle := style;
    WriteStringToIniFile('GENERAL', 'FormStyle', IntToStr(style));
end;
