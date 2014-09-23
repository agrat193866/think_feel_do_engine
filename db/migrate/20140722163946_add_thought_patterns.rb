class AddThoughtPatterns < ActiveRecord::Migration
  def up
    [
      {
        title: "All-or-Nothing (Black-or-White) Thinking",
        # description: "You see things in black-and-white categories. If your performance
        #     falls short of perfect, you see yourself as a total failure.",
        recommendations: "Try to engage in more balanced thinking. Are there shades of gray? Are there exceptions to your all or nothing thinking? Look for them. What if you looked at the issue along a continuum rather than in simple categories? Remember that things are usually somewhere between 0 and 100 percent and not one way or the other."

      },{
        title: "Overgeneralization",
        # description: "You see a single negative event as a never-ending pattern of defeat.",
        recommendations: "Are you condemning yourself based on a single event? What if you focused on describing rather than judging? Am I assuming that every situation and every person are the same? This is just one situation; one person. Can I remember other situations and people that are different?"
      },{
        title: "Mental Filter",
        # description: "You pick out a single negative defeat and dwell on it exclusively
        #     so that your vision of reality becomes darkened, like the drop of ink that
        #     colors the entire beaker of water.",
        recommendations: "Try to catch the positive. What are some positive things that discount your thought? How would you feel if you acknowledged the positive information? How might other people see this issue? Would they pick up on positive things that had happened? What would be the consequence if everyone didn't notice positive events and only saw things as negative?"
      },{
        title: "Discounting the Positive",
        # description: "You dismiss positive experiences by insisting they \"don't
        #   count\" for some reason or other. In this way you can maintain a negative
        #   belief that is contradicted by your everyday experiences.",
        recommendations: "Are you focusing on the negative side of things exclusively? Would you discount the positive characteristics of someone you care about? If not; then how come you would not count them for yourself? Are you overlooking your strengths and accomplishments? Make a list of things they went well today. It would be good to pat yourself on the back for something you've done."
      },{
        title: "Fortune Telling",
        # description: "You make a negative interpretation even though there are no
        #     definite facts that convincingly support your conclusion.",
        recommendations: "Can we really know what others are thinking? What are possible alternatives to why they might be behaving the way they are behaving? Can we really predict the future? What would it be like to find out how it really is rather than just imagine it?"
      },{
        title: "Magnification or Catastrophizing",
        # description: "You exaggerate the importance of things (such as your goof-up or
        #   someone else's achievement)",
        recommendations: "How big is this problem really? Where is it likely to really lead? How might you deal with this problem? Write an action plan. Are you telling yourself that you cannot possibly cope with this issue? If so; is it possible for you to identify or learn coping skills to deal with the challenge? Even if one possible outcome is catastrophic; is such a bad end likely to actually be the result? If it didn't end up being quite as bad; would it be as distressing?"
      },{
        title: "Minimization",
        # description: "You inappropriately shrink things until they
        #   appear tiny (your own desirable qualities or the other fellow's
        #   imperfections). This is also called the \"binocular trick.\"",
        recommendations: "Is it possible the positive thing is true? What would happen if you accepted a positive statement? What are the advantages/disadvantages of continuing to minimize positive things? What would happen if everyone minimized? What if a friend minimized positive things that you said to him or her? Are you overlooking your strengths and accomplishments? Remember; even small steps are progress.  Is the standard you are setting for yourself fair? Are your expectations reasonable?"
      },{
        title: "Emotional Reasoning",
        # description: "You assume that your negative emotions necessarily reflect the
        #   way things really are: \"I feel it, therefore it must be true.\"",
        recommendations: "Is that your head or heart?"
      },{
        title: "\"Should\" Statements",
        # description: "You try to motivate yourself with shoulds and shouldn'ts, as if
        #   you had to be whipped and punished before you could be expected to do
        #   anything. \"Musts\" and \"oughts\" are also offenders. The emotional
        #   consequence is guilt.

        #   When you direct should statements toward others, you feel anger,
        #   frustration, and resentment.",
        recommendations: "Shoulda coulda woulda"
      },{
        title: "Labeling and Mislabeling",
        # description: "This is an extreme form of overgeneralization. Instead of
        #   describing your error, you attach a negative label to yourself: \"I'm a
        #   loser.\" When someone else's behavior rubs you the wrong way, you attach a
        #   negative label to him: \"He's a goddam louse\".

        #   Mislabeling involves describing an event with language that is highly
        #   colored and emotionally loaded.",
        recommendations: "Is it so simple?"
      },{
        title: "Personalization",
        # description: "You see yourself as the cause of some negative external event
        #     which in fact you were not primarily responsible for.",
        recommendations: "Is that yours to take on?"
      }
    ].each do |thought_pattern|
      tp = ThoughtPattern.find_by_title(thought_pattern[:title])
      if tp
        tp.update_attributes(recommendations: thought_pattern[:recommendations])
        puts "ThoughtPattern with title was created!"
      else
        puts "ThoughtPattern with title '#{thought_pattern[:title]}' doesn't exist!"
      end
    end
  end
end
