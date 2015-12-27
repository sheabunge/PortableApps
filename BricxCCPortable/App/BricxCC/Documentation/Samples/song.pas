program midi;

uses
  dsound, unistd;

const
  music : array[0..7] of note_t = (
  ( PITCH_PAUSE, 120 ),
  ( PITCH_G6, 1 ),
  ( PITCH_PAUSE, 7 ),
  ( PITCH_G5, 2 ),
  ( PITCH_PAUSE, 8 ),
  ( PITCH_G6, 9 ),
  ( PITCH_PAUSE, 11 ),
  ( PITCH_END, 0 )
  );

begin
  dsound_16th_ms := 10;
  dsound_play(@music[0]);
  sleep(1);
end.

