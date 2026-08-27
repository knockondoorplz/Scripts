// -----------------------------------------------------------------------------
// WindowEcology
//
// This object doesn't move windows.
//
// It thinks about windows.
//
// Think of it as an ecologist walking through a forest,
// measuring trees before deciding how the forest should evolve.
//
// Every future feature—Chronolog, Virescent, learning,
// "Roll Again", Panorama—starts here.
// -----------------------------------------------------------------------------

class WindowEcology
{
public:

    void ScanDesktop();

    void ScoreCurrentLayout();

    void GenerateCandidates();

    void Roll();

private:

    std::vector<Window> windows;

    std::vector<Layout> candidates;

    float experimental = 0.20f;

};