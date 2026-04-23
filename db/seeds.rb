User.find_or_create_by!(email: 'aba@kaleidoscopekollege.com') do |user|
  user.first_name = 'Corie'
  user.last_name = ' '
  user.password = '123456'
  user.role = 'admin'
end

company = WebsiteDetail.find_or_initialize_by(email: 'aba@kaleidoscopekollege.com')

company.update!(
  name: 'Kaleidoscope Kollege',
  email: 'ABA@KALEIDOSCOPEKOLLEGE.COM',
  phone_1: '(443) 822-4357',
  phone_2: '(703) 718-6085',
  address_1: 'Online Learning | Maryland | Washington, DC | Northern, VA ',
  address_2: '5900 Balcones Drive, STE 100 Austin TX 78731',
  instagram: 'https://www.instagram.com/kaleidoscopekollege',
  facebook: 'https://www.facebook.com/Kaleidoscopekollege',
  linkedin: 'https://www.linkedin.com/in/kaleidoscope-kollege-ba1b633b2/?skipRedirect=true',
  about: 'Providing comprehensive therapy and specialized support services to help individuals reach their full potential in life, learning, and community through evidence-based behavioral strategies combined with compassionate care.'
)


puts "Seeding Services & Courses..."

services_data = [
  {
    title: "Behavior Technician",
    description: "Trained professionals who implement behavior intervention plans, collect data, and support individuals in developing essential life, communication, and social skills through evidence-based techniques.",
    image: 'service_1.png',
    courses: [
      {
        title: "Understanding Behavior Data Collection",
        category: "ABA",
        difficulty: "Beginner – Intermediate",
        videos_count: 28,
        duration_weeks: 6,
        total_hours: 5,
        assignments: "Weekly Practice Activities",
        price: 5.99,
        description: '',
        summary: "In Applied Behavior Analysis (ABA), data collection is critical for understanding behavior patterns and making informed decisions. In this course, you’ll learn how to collect, analyze, and interpret behavior data to track children’s progress, identify trends, and guide behavior management strategies. This course will help you develop the skills to use data as a tool for improving behavior, academic engagement, and emotional regulation. With real-life examples, interactive quizzes, and visual aids, you’ll gain a deeper understanding of how data informs decisions and supports children’s development.",
        image: 'course_1.png',
        instructor: {
          name: "Dr. Sarah Johnson",
          email: "sarah.johnson@example.com",
          designation: "Clinical Psychologist",
          profile_description: "10+ years of experience in Clinical Psychologist.",
          rating: 4.8,
          specialist: "Clinical Psychologist",
          image: 'Card.png'
        }
      }
    ]
  }
]

puts "Seeding Services, Courses & Instructors..."

services_data.each do |service_data|
  service = Service.find_or_initialize_by(title: service_data[:title])

  service.update!(
    description: service_data[:description]
  )

  image_path = Rails.root.join("app/assets/images/services/#{service_data[:image]}")

  if File.exist?(image_path)
    service.image.attach(
      io: File.open(image_path),
      filename: service_data[:image],
      content_type: Marcel::MimeType.for(Pathname.new(image_path))
    )
  end


  service_data[:courses].each do |course_data|
    # Create Instructor (one per course)
    if course_data[:instructor]
      instructor = Instructor.find_or_initialize_by(
        email: course_data[:instructor][:email]
      )
      instructor.update!(
        name: course_data[:instructor][:name],
        designation: course_data[:instructor][:designation],
        profile_description: course_data[:instructor][:profile_description],
        rating: course_data[:instructor][:rating],
        specialist: course_data[:instructor][:specialist]
      )
      image_path = Rails.root.join("app/assets/images/#{course_data[:instructor][:image]}")
      if File.exist?(image_path)
        instructor.image.attach(
          io: File.open(image_path),
          filename: course_data[:instructor][:image],
          content_type: Marcel::MimeType.for(Pathname.new(image_path))
        )
      end
    end
    course = Course.find_or_initialize_by(
      title: course_data[:title],
      service: service,
      instructor: instructor
    )

    course.update!(
      category: course_data[:category],
      difficulty: course_data[:difficulty],
      videos_count: course_data[:videos_count],
      duration_weeks: course_data[:duration_weeks],
      total_hours: course_data[:total_hours],
      assignments: course_data[:assignments],
      price: course_data[:price],
      summary: course_data[:summary]
    )
    image_path = Rails.root.join("app/assets/images/courses#{course_data[:image]}")
    if File.exist?(image_path)
      course.image.attach(
        io: File.open(image_path),
        filename: course_data[:image],
        content_type: Marcel::MimeType.for(Pathname.new(image_path))
      )
    end
  end
end

puts "✅ Services, Courses & Instructors seeded successfully!"
