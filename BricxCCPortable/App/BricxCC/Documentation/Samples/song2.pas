program midi;

uses
  dsound;

const
  music : array[0..9] of note_t = (
  ( PITCH_PAUSE, 120 ),
  ( PITCH_Gm4, 1 ),
  ( PITCH_PAUSE, 7 ),
  ( PITCH_E5, 2 ),
  ( PITCH_PAUSE, 8 ),
  ( PITCH_D6, 1 ),
  ( PITCH_PAUSE, 7 ),
  ( PITCH_Fm6, 6 ),
  ( PITCH_PAUSE, 8 ),
  ( PITCH_END, 0 )
  );

begin
  dsound_set_duration(40);
  dsound_play(@music[0]);
end.

